//
//  ToxManager.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 18.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxManager.h"
#import "ToxManager+Private.h"
#import "ToxManagerAvatars.h"
#import "ToxManagerFriends.h"
#import "ToxManager+PrivateChat.h"
#import "ToxManager+PrivateFiles.h"
#import "ToxFunctions.h"
#import "UserInfoManager.h"
#import "ProfileManager.h"
#import "Helper.h"

static NSString *const kToxSaveName = @"tox_save";

static ToxManager *__instance;
static dispatch_once_t __onceToken;

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

            _managerAvatars = [[ToxManagerAvatars alloc] initOnToxQueueWithToxManager:self];
            _managerFriends = [[ToxManagerFriends alloc] initOnToxQueueWithToxManager:self];

            [self qRegisterChatsCallbacks];
            [self qRegisterFilesCallbacksAndSetup];

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

    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance
{
    dispatch_once(&__onceToken, ^{
        __instance = [[ToxManager alloc] initPrivate];
    });

    return __instance;
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

- (void)killSharedInstance
{
    __instance = nil;
    __onceToken = 0;
}

- (void)bootstrapWithNodes:(NSArray *)nodes
{
    dispatch_async(self.queue, ^{
        [self qBootstrapWithNodes:nodes];
    });
}

- (void)sendFriendRequestWithAddress:(NSString *)addressString message:(NSString *)messageString
{
    dispatch_async(self.queue, ^{
        [self.managerFriends qSendFriendRequestWithAddress:addressString message:messageString];
    });
}

- (void)approveFriendRequest:(ToxFriendRequest *)request withBlock:(void (^)(BOOL wasError))block
{
    dispatch_async(self.queue, ^{
        [self.managerFriends qApproveFriendRequest:request withBlock:block];
    });
}

- (void)removeFriendRequest:(ToxFriendRequest *)request
{
    dispatch_async(self.queue, ^{
        [self.managerFriends qRemoveFriendRequest:request];
    });
}

- (void)removeFriend:(ToxFriend *)friend
{
    dispatch_async(self.queue, ^{
        [self.managerFriends qRemoveFriend:friend];
    });
}

- (void)changeNicknameTo:(NSString *)name forFriend:(ToxFriend *)friendToChange
{
    dispatch_async(self.queue, ^{
        [self.managerFriends qChangeNicknameTo:name forFriend:friendToChange];
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
                                                  fileNumber:message.pendingFile.fileNumber
                                                  isOutgoing:[Helper isOutgoingMessage:message]];
}

- (void)togglePauseForPendingFileInMessage:(CDMessage *)message
{
    dispatch_async(self.queue, ^{
        [self qTogglePauseForPendingFileInMessage:message];
    });
}

- (void)uploadData:(NSData *)data withFileName:(NSString *)fileName toChat:(CDChat *)chat
{
    dispatch_async(self.queue, ^{
        [self qUploadData:data withFileName:fileName toChat:chat];
    });
}

- (void)updateAvatar:(UIImage *)image
{
    dispatch_async(self.queue, ^{
        [self.managerAvatars qUpdateAvatar:image];
    });
}

- (BOOL)userHasAvatar
{
    return [self.managerAvatars synchronizedUserHasAvatar];
}

- (UIImage *)userAvatar
{
    return [self.managerAvatars synchronizedUserAvatar];
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

    NSData *toxData = [[ProfileManager sharedInstance] toxDataForCurrentProfile];

    if (toxData.length) {
        DDLogInfo(@"ToxManager: creating tox... old data found, loading");
        tox_load(_tox, (uint8_t *)toxData.bytes, (uint32_t)toxData.length);
    }
    else {
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
        ToxManager *strongSelf = weakSelf;

        if (! strongSelf) {
            return;
        }

        tox_do(strongSelf.tox);

        int isConnected = tox_isconnected(strongSelf.tox);

        if (isConnected != strongSelf.isConnected) {
            strongSelf.isConnected = isConnected;
            DDLogInfo(@"ToxManager: ***  connected changed to %d  ***", isConnected);
        }

        uint32_t newInterval = tox_do_interval(strongSelf.tox);

        if (newInterval != strongSelf.timerMillisecondsUpdateInterval) {
            dispatch_async(strongSelf.queue, ^{
                [strongSelf qUpdateTimerInterval:newInterval];
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
                node.address, (unsigned long)node.port, node.publicKey);

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

    NSData *nsData = [NSData dataWithBytes:data length:size];
    [[ProfileManager sharedInstance] saveToxDataForCurrentProfile:nsData];

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

- (BOOL)isOnToxManagerQueue
{
    return dispatch_get_specific(kIsOnToxManagerQueue);
}

@end

