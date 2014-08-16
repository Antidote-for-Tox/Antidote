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
            [self qRegisterFilesCallbacks];;

            [self qLoadFriendsAndCreateContainer];
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

- (void)bootstrapWithAddress:(NSString *)address port:(NSUInteger)port publicKey:(NSString *)publicKey
{
    dispatch_async(self.queue, ^{
        [self qBootstrapWithAddress:address port:port publicKey:publicKey];
    });
}

- (void)sendFriendRequestWithAddress:(NSString *)addressString message:(NSString *)messageString
{
    dispatch_async(self.queue, ^{
        [self qSendFriendRequestWithAddress:addressString message:messageString];
    });
}

- (void)markAllFriendRequestsAsSeen
{
    dispatch_async(self.queue, ^{
        [self qMarkAllFriendRequestsAsSeen];
    });
}

- (void)approveFriendRequest:(ToxFriendRequest *)request wasError:(BOOL *)wasError
{
    dispatch_async(self.queue, ^{
        [self qApproveFriendRequest:request wasError:wasError];
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

#pragma mark -  Notifications

- (void)applicationWillTerminateNotification:(NSNotification *)notification
{
    dispatch_sync(self.queue, ^{
        [self qSaveTox];
        tox_kill(self.tox);
    });
}

#pragma mark -  Private

- (void)qCreateTox
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    NSLog(@"ToxManager: creating tox");
    _tox = tox_new(TOX_ENABLE_IPV6_DEFAULT);

    NSData *toxData = [UserInfoManager sharedInstance].uToxData;

    if (toxData) {
        NSLog(@"ToxManager: old data found, loading...");
        tox_load(_tox, (uint8_t *)toxData.bytes, (uint32_t)toxData.length);
    }
    else {
        [self qSaveTox];
    }
}

- (void)qMaybeStartTimer
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    if (self.timer) {
        return;
    }

    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);

    [self qUpdateTimerInterval:tox_do_interval(self.tox)];

    __weak ToxManager *weakSelf = self;

    dispatch_source_set_event_handler(self.timer, ^{
        tox_do(weakSelf.tox);

        int isConnected = tox_isconnected(weakSelf.tox);

        if (isConnected != weakSelf.isConnected) {
            weakSelf.isConnected = isConnected;
            NSLog(@"ToxManager: connected changed to %d", isConnected);
        }

        uint32_t newInterval = tox_do_interval(weakSelf.tox);

        if (newInterval != weakSelf.timerMillisecondsUpdateInterval) {
            [weakSelf qUpdateTimerInterval:newInterval];
        }
    });
    dispatch_resume(self.timer);
}

- (void)qUpdateTimerInterval:(uint32_t)newInterval
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    self.timerMillisecondsUpdateInterval = newInterval;

    uint64_t actualInterval = newInterval * (NSEC_PER_SEC / 1000);

    dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), actualInterval, actualInterval / 5);
}

- (void)qBootstrapWithAddress:(NSString *)address port:(NSUInteger)port publicKey:(NSString *)publicKey
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    uint8_t *pub_key = [ToxFunctions hexStringToBin:publicKey];
    tox_bootstrap_from_address(self.tox, address.UTF8String, 1, htons(port), pub_key);
    free(pub_key);

    [self qMaybeStartTimer];
}

- (void)qSaveTox
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    uint32_t size = tox_size(_tox);
    uint8_t *data = malloc(size);

    tox_save(_tox, data);

    [UserInfoManager sharedInstance].uToxData = [NSData dataWithBytes:data length:size];

    free(data);
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

@end

