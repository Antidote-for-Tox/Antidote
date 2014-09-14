//
//  ToxManager.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 18.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxManager.h"
#import "ToxManager+Private.h"
#import "ToxManager+PrivateFriends.h"
#import "ToxManager+PrivateChat.h"
#import "ToxManager+PrivateFiles.h"
#import "ToxFunctions.h"
#import "UserInfoManager.h"

static NSString *const kToxSaveName = @"tox_save";

@implementation ToxManager
@synthesize clientId = _clientId;

#pragma mark -  Lifecycle

- (id)init
{
    return nil;
}

- (id)initPrivate
{
    self = [super init];

    if (self) {
        _queue = dispatch_queue_create("me.dvor.antidote.ToxManager", NULL);
        _toxDoQueue = dispatch_queue_create("me.dvor.antidote.ToxManager_toxDo", NULL);

        {
            // The dispatch_queue_set_specific() and dispatch_get_specific() functions take a
            // "void *key" parameter.
            // From the documentation:
            //
            // > Keys are only compared as pointers and are never dereferenced.
            // > Thus, you can use a pointer to a static variable for a specific subsystem or
            // > any other value that allows you to identify the value uniquely.

            // assigning to variable its address, so we can use kIsOnToxManagerQueue
            // instead of &kIsOnToxManagerQueue.
            kIsOnToxManagerQueue = &kIsOnToxManagerQueue;

            void *nonNullUnusedPointer = (__bridge void *)self;

            dispatch_queue_set_specific(_queue, kIsOnToxManagerQueue, nonNullUnusedPointer, NULL);
        }

        dispatch_sync(self.queue, ^{
            [self qCreateTox];
            [self qRegisterFriendsCallbacks];
            [self qRegisterChatsCallbacks];
            [self qRegisterFilesCallbacksAndSetup];

            [self qLoadFriendsAndCreateContainer];

            DDLogInfo(@"ToxManager: created");
        });

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminateNotification:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }

    return self;
}

- (void)dealloc
{
    DDLogInfo(@"ToxManager: dealloc called, killing tox");
    tox_kill(_tox);

    dispatch_source_cancel(self.timer);
    self.timer = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance
{
    static ToxManager *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[ToxManager alloc] initPrivate];
    });

    return instance;
}

#pragma mark -  Properties

- (NSString *)toxId
{
    __block NSString *toxId;

    dispatch_sync(self.queue, ^{
        toxId = [self qToxId];
    });

    return toxId;
}

- (NSString *)clientId
{
    if (! _clientId) {
        dispatch_sync(self.queue, ^{
            _clientId = [self qClientId];
        });
    }
    return _clientId;
}

- (NSString *)userName
{
    __block NSString *userName;

    dispatch_sync(self.queue, ^{
        userName = [self qUserName];
    });

    return userName;
}

- (void)setUserName:(NSString *)userName
{
    dispatch_async(self.queue, ^{
        [self qSetUserName:userName];
    });
}

- (NSString *)userStatusMessage
{
    __block NSString *userStatusMessage;

    dispatch_sync(self.queue, ^{
        userStatusMessage = [self qUserStatusMessage];
    });

    return userStatusMessage;
}

- (void)setUserStatusMessage:(NSString *)statusMessage
{
    dispatch_async(self.queue, ^{
        [self qSetUserStatusMessage:statusMessage];
    });
}

#pragma mark -  Public

- (void)bootstrapWithNodes:(NSArray *)nodes
{
    dispatch_async(self.queue, ^{
        [self qBootstrapWithNodes:nodes];
    });
}

- (void)sendFriendRequestWithAddress:(NSString *)addressString message:(NSString *)messageString
{
    dispatch_async(self.queue, ^{
        [self qSendFriendRequestWithAddress:addressString message:messageString];
    });
}

- (void)approveFriendRequest:(ToxFriendRequest *)request withBlock:(void (^)(BOOL wasError))block
{
    dispatch_async(self.queue, ^{
        [self qApproveFriendRequest:request withBlock:block];
    });
}

- (void)removeFriendRequest:(ToxFriendRequest *)request
{
    dispatch_async(self.queue, ^{
        [self qRemoveFriendRequest:request];
    });
}

- (void)removeFriend:(ToxFriend *)friend
{
    dispatch_async(self.queue, ^{
        [self qRemoveFriend:friend];
    });
}

- (void)changeAssociatedNameTo:(NSString *)name forFriend:(ToxFriend *)friendToChange
{
    dispatch_async(self.queue, ^{
        [self qChangeAssociatedNameTo:name forFriend:friendToChange];
    });
}

- (void)changeIsTypingInChat:(CDChat *)chat to:(BOOL)isTyping
{
    dispatch_async(self.queue, ^{
        [self qChangeIsTypingInChat:chat to:isTyping];
    });
}

- (void)sendMessage:(NSString *)message toChat:(CDChat *)chat
{
    dispatch_async(self.queue, ^{
        [self qSendMessage:message toChat:chat];
    });
}

- (void)chatWithToxFriend:(ToxFriend *)friend completionBlock:(void (^)(CDChat *chat))completionBlock
{
    if (! completionBlock) {
        return;
    }

    if (! friend) {
        completionBlock(nil);
    }

    dispatch_async(self.queue, ^{
        [self qChatWithToxFriend:friend completionBlock:^(CDChat *chat) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(chat);
            });
        }];
    });
}

- (void)acceptOrRefusePendingFileInMessage:(CDMessage *)message accept:(BOOL)accept
{
    dispatch_async(self.queue, ^{
        [self qAcceptOrRefusePendingFileInMessage:message accept:accept];
    });
}

- (CGFloat)progressForPendingFileInMessage:(CDMessage *)message
{
    if (! message.pendingFile) {
        return 0.0;
    }

    return [self synchronizedProgressForFileWithFriendNumber:message.pendingFile.friendNumber
                                                  fileNumber:message.pendingFile.fileNumber];
}

- (void)togglePauseForPendingFileInMessage:(CDMessage *)message
{
    dispatch_async(self.queue, ^{
        [self qTogglePauseForPendingFileInMessage:message];
    });
}

#pragma mark -  Notifications

- (void)applicationWillTerminateNotification:(NSNotification *)notification
{
    dispatch_sync(self.queue, ^{
        DDLogInfo(@"ToxManager: applicationWillTerminateNotification: saving and killing tox...");

        [self qSaveTox];
        tox_kill(self.tox);

        DDLogInfo(@"ToxManager: applicationWillTerminateNotification: saving and killing tox... done");
    });
}

#pragma mark -  Private

- (void)qCreateTox
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager: creating tox...");

    _tox = tox_new(NULL);

    NSString *directory = [self directoryWithToxSaves];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (! [fileManager fileExistsAtPath:directory]) {
        [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSString *path = [directory stringByAppendingPathComponent:kToxSaveName];
    NSData *toxData = [NSData dataWithContentsOfFile:path];

    if (toxData) {
        DDLogInfo(@"ToxManager: creating tox... old data found, loading");
        tox_load(_tox, (uint8_t *)toxData.bytes, (uint32_t)toxData.length);
    }
    else {
#warning Added for compatibility with 0.1 version. Remove in future (after few alpha versions).
        {
            // trying to load tox from user defaults (it was stored there in 0.1 version
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            toxData = [defaults objectForKey:@"tox-data"];

            if (toxData) {
                DDLogInfo(@"ToxManager: creating tox... found old data in NSUserDefaults, moving it to file");

                [defaults removeObjectForKey:@"tox-data"];
                [defaults synchronize];

                tox_load(_tox, (uint8_t *)toxData.bytes, (uint32_t)toxData.length);
            }
        }

        DDLogInfo(@"ToxManager: creating tox... no old data, new tox has been created");
        [self qSaveTox];
    }
}

- (void)qMaybeStartTimer
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager: starting timer...");

    if (self.timer) {
        DDLogWarn(@"ToxManager: starting timer... already started");
        return;
    }

    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.toxDoQueue);

    [self qUpdateTimerInterval:tox_do_interval(self.tox)];

    __weak ToxManager *weakSelf = self;

    dispatch_source_set_event_handler(self.timer, ^{
        tox_do(weakSelf.tox);

        int isConnected = tox_isconnected(weakSelf.tox);

        if (isConnected != weakSelf.isConnected) {
            weakSelf.isConnected = isConnected;
            DDLogInfo(@"ToxManager: ***  connected changed to %d  ***", isConnected);
        }

        uint32_t newInterval = tox_do_interval(weakSelf.tox);

        if (newInterval != weakSelf.timerMillisecondsUpdateInterval) {
            dispatch_async(weakSelf.queue, ^{
                [weakSelf qUpdateTimerInterval:newInterval];
            });
        }
    });
    dispatch_resume(self.timer);

    DDLogInfo(@"ToxManager: starting timer... started");
}

- (void)qUpdateTimerInterval:(uint32_t)newInterval
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    self.timerMillisecondsUpdateInterval = newInterval;

    uint64_t actualInterval = newInterval * (NSEC_PER_SEC / 1000);

    dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), actualInterval, actualInterval / 5);
}

- (void)qBootstrapWithNodes:(NSArray *)nodes
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    for (ToxNode *node in nodes) {
        DDLogInfo(@"ToxManager: bootstraping with address %@, port %lu, publicKey %@",
                node.address, node.port, node.publicKey);

        uint8_t *pub_key = [ToxFunctions hexStringToBin:node.publicKey];
        tox_bootstrap_from_address(self.tox, node.address.UTF8String, node.port, pub_key);
        free(pub_key);
    }

    [self qMaybeStartTimer];
}

- (void)qSaveTox
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager: saving tox...");

    uint32_t size = tox_size(_tox);
    uint8_t *data = malloc(size);

    tox_save(_tox, data);

    NSString *path = [self directoryWithToxSaves];
    path = [path stringByAppendingPathComponent:kToxSaveName];

    NSData *nsData = [NSData dataWithBytes:data length:size];
    [nsData writeToFile:path atomically:NO];

    free(data);

    DDLogInfo(@"ToxManager: saving tox... saved, size = %d", size);
}

- (NSString *)qToxId
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    uint8_t *address = malloc(TOX_FRIEND_ADDRESS_SIZE);
    tox_get_address(self.tox, address);

    NSString *toxId = [ToxFunctions addressToString:address];

    free(address);

    return toxId;
}

- (NSString *)qClientId
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    return [ToxFunctions addressToClientId:[self qToxId]];
}

- (NSString *)qUserName
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    uint8_t *name = malloc(TOX_MAX_NAME_LENGTH);
    int size = tox_get_self_name(self.tox, name);

    NSString *userName = [[NSString alloc] initWithBytes:name length:size encoding:NSUTF8StringEncoding];

    free(name);

    return userName;
}

- (void)qSetUserName:(NSString *)userName
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    NSString *oldUserName = [self qUserName];;

    if (userName && oldUserName && [userName isEqualToString:oldUserName]) {
        return;
    }

    DDLogInfo(@"ToxManager: changing userName to %@", userName);

    if (userName.length > TOX_MAX_NAME_LENGTH) {
        userName = [userName substringToIndex:TOX_MAX_NAME_LENGTH];
    }

    const char *name = [userName cStringUsingEncoding:NSUTF8StringEncoding];

    int result = tox_set_name(self.tox, (uint8_t *)name, [userName lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);

    if (result == 0) {
        [self qSaveTox];
    }
}

- (NSString *)qUserStatusMessage
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    int size = tox_get_self_status_message_size(self.tox);

    uint8_t *message = malloc(size);
    tox_get_self_status_message(self.tox, message, size);

    NSString *statusMessage = [[NSString alloc] initWithBytes:message length:size encoding:NSUTF8StringEncoding];

    free(message);

    return statusMessage;
}

- (void)qSetUserStatusMessage:(NSString *)statusMessage
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    NSString *oldUserStatusMessage = [self qUserStatusMessage];

    if (statusMessage && oldUserStatusMessage && [statusMessage isEqualToString:oldUserStatusMessage]) {
        return;
    }

    DDLogInfo(@"ToxManager: changing statusMessage to %@", statusMessage);

    if (statusMessage.length > TOX_MAX_STATUSMESSAGE_LENGTH) {
        statusMessage = [statusMessage substringToIndex:TOX_MAX_STATUSMESSAGE_LENGTH];
    }

    const char *message = [statusMessage cStringUsingEncoding:NSUTF8StringEncoding];

    int result = tox_set_status_message(
            self.tox,
            (uint8_t *)message,
            [statusMessage lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);

    if (result == 0) {
        [self qSaveTox];
    }
}

- (NSString *)directoryWithToxSaves
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

    return [path stringByAppendingPathComponent:@"ToxSaves"];
}

@end

