//
//  ToxManager.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 18.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxManager.h"
#import "ToxFunctions.h"
#import "UserInfoManager.h"
#import "CoreDataManager+User.h"
#import "CoreDataManager+Chat.h"
#import "CoreDataManager+Message.h"
#import "ToxFriend+Private.h"
#import "EventsManager.h"
#import "AppDelegate.h"

void friendRequestCallback(Tox *tox, const uint8_t * public_key, const uint8_t * data, uint16_t length, void *userdata);
void friendMessageCallback(Tox *tox, int32_t friendnumber, const uint8_t *message, uint16_t length, void *userdata);
void nameChangeCallback(Tox *tox, int32_t friendnumber, const uint8_t *newname, uint16_t length, void *userdata);
void statusMessageCallback(Tox *tox, int32_t friendnumber, const uint8_t *newstatus, uint16_t length, void *userdata);
void userStatusCallback(Tox *tox, int32_t friendnumber, uint8_t status, void *userdata);
void typingChangeCallback(Tox *tox, int32_t friendnumber, uint8_t isTyping, void *userdata);
void readReceiptCallback(Tox *tox, int32_t friendnumber, uint32_t receipt, void *userdata);
void connectionStatusCallback(Tox *tox, int32_t friendnumber, uint8_t status, void *userdata);

@interface ToxManager()
{
    void *kIsOnToxManagerQueue;
}

@property (assign, nonatomic, readonly) Tox *tox;

@property (strong, nonatomic, readonly) dispatch_queue_t queue;

@property (strong, nonatomic) dispatch_source_t timer;
@property (assign, nonatomic) uint32_t timerMillisecondsUpdateInterval;

@property (assign, nonatomic) BOOL isConnected;

@end


@implementation ToxManager

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
    __block NSString *clientId;

    dispatch_sync(self.queue, ^{
        clientId = [self qClientId];
    });

    return clientId;
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

#pragma mark -  Notifications

- (void)applicationWillTerminateNotification:(NSNotification *)notification
{
    dispatch_sync(self.queue, ^{
        [self qSaveTox];
        tox_kill(self.tox);
    });
}

#pragma mark -  Private methods that should run only on Tox queue

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

    int result = tox_set_name(self.tox, (uint8_t *)name, userName.length);

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

    int result = tox_set_status_message(self.tox, (uint8_t *)message, statusMessage.length);

    if (result == 0) {
        [self qSaveTox];
    }
}

- (void)qBootstrapWithAddress:(NSString *)address port:(NSUInteger)port publicKey:(NSString *)publicKey
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    uint8_t *pub_key = [ToxFunctions hexStringToBin:publicKey];
    tox_bootstrap_from_address(self.tox, address.UTF8String, 1, htons(port), pub_key);
    free(pub_key);

    [self qMaybeStartTimer];
}

- (void)qSendFriendRequestWithAddress:(NSString *)addressString message:(NSString *)messageString
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    if (! messageString.length) {
        messageString = NSLocalizedString(@"Please, add me", @"Tox empty message");
    }

    uint8_t *address = [ToxFunctions hexStringToBin:addressString];
    const char *message = [messageString cStringUsingEncoding:NSUTF8StringEncoding];

    int32_t result = tox_add_friend(self.tox, address, (const uint8_t *)message, messageString.length);

    free(address);

    if (result > -1) {
        [self qSaveTox];

        [self.friendsContainer private_addFriend:[self qCreateFriendWithId:result]];
    }
    else {

    }
}

- (void)qMarkAllFriendRequestsAsSeen
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    [self.friendsContainer private_markAllFriendRequestsAsSeen];
}

- (void)qApproveFriendRequest:(ToxFriendRequest *)request wasError:(BOOL *)wasError
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    uint8_t *clientId = [ToxFunctions hexStringToBin:request.clientId];
    uint32_t friendId = tox_add_friend_norequest(self.tox, clientId);
    free(clientId);

    if (friendId == -1) {
        if (wasError) {
            *wasError = YES;
        }
    }
    else {
        [self qSaveTox];

        [self.friendsContainer private_removeFriendRequest:request];
        [self.friendsContainer private_addFriend:[self qCreateFriendWithId:friendId]];
    }
}

- (void)qRemoveFriendRequest:(ToxFriendRequest *)request
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    if (! request) {
        return;
    }

    [self.friendsContainer private_removeFriendRequest:request];
}

- (void)qRemoveFriend:(ToxFriend *)friend
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    if (! friend) {
        return;
    }

    tox_del_friend(self.tox, friend.id);
    [self qSaveTox];

    [self.friendsContainer private_removeFriend:friend];
}

- (void)qChangeAssociatedNameTo:(NSString *)name forFriend:(ToxFriend *)friendToChange
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    [self.friendsContainer private_updateFriendWithId:friendToChange.id updateBlock:^(ToxFriend *friend) {
        if (! friend.clientId) {
            return;
        }

        friend.associatedName = name;

        if (name.length) {
            NSMutableDictionary *names = [NSMutableDictionary dictionaryWithDictionary:
                [UserInfoManager sharedInstance].uAssociatedNames];

            names[friend.clientId] = name;

            [UserInfoManager sharedInstance].uAssociatedNames = [names copy];
        }
        else {
            [[ToxManager sharedInstance] qMaybeCreateAssociatedNameForFriend:friend];
        }
    }];
}

- (void)qChangeIsTypingInChat:(CDChat *)chat to:(BOOL)isTyping
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    if (! chat) {
        return;
    }

    CDUser *user = [chat.users anyObject];
    ToxFriend *friend = [self.friendsContainer friendWithClientId:user.clientId];

    uint8_t typing = isTyping ? 1 : 0;
    tox_set_user_is_typing(self.tox, friend.id, typing);
}

- (void)qSendMessage:(NSString *)message toChat:(CDChat *)chat
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    if (! message.length || ! chat) {
        return;
    }

    if (chat.users.count > 1) {
        NSLog(@"group chat isn't supported yet");
        return;
    }

    CDUser *user = [chat.users anyObject];

    ToxFriend *friend = [self.friendsContainer friendWithClientId:user.clientId];

    const char *cMessage = [message cStringUsingEncoding:NSUTF8StringEncoding];

    tox_send_message(self.tox, friend.id, (uint8_t *)cMessage, message.length);

    __weak ToxManager *weakSelf = self;

    [self qUserFromClientId:[self qClientId] completionBlock:^(CDUser *currentUser) {
        [weakSelf qAddMessage:message toChat:chat fromUser:currentUser completionBlock:nil];
    }];
}

- (void)qChatWithToxFriend:(ToxFriend *)friend completionBlock:(void (^)(CDChat *chat))completionBlock
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    __weak ToxManager *weakSelf = self;

    [self qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {

        [weakSelf qChatWithUser:user completionBlock:completionBlock];
    }];
}

- (void)qCreateTox
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    NSLog(@"ToxManager: creating tox");
    _tox = tox_new(TOX_ENABLE_IPV6_DEFAULT);

    NSData *toxData = [UserInfoManager sharedInstance].uToxData;

    if (toxData) {
        NSLog(@"ToxManager: old data found, loading...");
        tox_load(_tox, (uint8_t *)toxData.bytes, toxData.length);
    }
    else {
        [self qSaveTox];
    }

    tox_callback_friend_request    (_tox, friendRequestCallback,     NULL);
    tox_callback_friend_message    (_tox, friendMessageCallback,     NULL);
    tox_callback_name_change       (_tox, nameChangeCallback,        NULL);
    tox_callback_status_message    (_tox, statusMessageCallback,     NULL);
    tox_callback_user_status       (_tox, userStatusCallback,        NULL);
    tox_callback_typing_change     (_tox, typingChangeCallback,      NULL);
    tox_callback_read_receipt      (_tox, readReceiptCallback,       NULL);
    tox_callback_connection_status (_tox, connectionStatusCallback,  NULL);
}

- (void)qLoadFriendsAndCreateContainer
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    uint32_t friendsCount = tox_count_friendlist(self.tox);
    uint32_t listSize = friendsCount * sizeof(int32_t);

    int32_t *friendsList = malloc(listSize);

    tox_get_friendlist(self.tox, friendsList, listSize);

    NSMutableArray *friendsArray = [NSMutableArray new];

    for (NSUInteger index = 0; index < friendsCount; index++) {
        int32_t friendId = friendsList[index];

        [friendsArray addObject:[self qCreateFriendWithId:friendId]];
    }

    _friendsContainer = [[ToxFriendsContainer alloc] initWithFriendsArray:[friendsArray copy]];

    free(friendsList);
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

- (ToxFriend *)qCreateFriendWithId:(int32_t)friendId
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    if (! tox_friend_exists(self.tox, friendId)) {
        return nil;
    }

    ToxFriend *friend = [ToxFriend new];
    friend.id = friendId;

    {
        uint8_t *clientId = malloc(TOX_CLIENT_ID_SIZE);

        int result = tox_get_client_id(self.tox, friendId, clientId);

        if (result == 0) {
            friend.clientId = [ToxFunctions clientIdToString:clientId];
            free(clientId);
        }
    }

    {
        uint8_t *name = malloc(TOX_MAX_NAME_LENGTH);
        int length = tox_get_name(self.tox, friendId, name);

        if (length > 0) {
            friend.realName = [NSString stringWithCString:(const char*)name encoding:NSUTF8StringEncoding];
            free(name);
        }
    }

    {
        uint64_t lastOnline = tox_get_last_online(self.tox, friendId);

        if (lastOnline > 0) {
            friend.lastSeenOnline = [NSDate dateWithTimeIntervalSince1970:lastOnline];
        }
    }

    friend.isTyping = tox_get_is_typing(self.tox, friendId);

    {
        if (friend.clientId) {
            NSDictionary *names = [UserInfoManager sharedInstance].uAssociatedNames;

            friend.associatedName = names[friend.clientId];
        }
    }

    [self qMaybeCreateAssociatedNameForFriend:friend];

    return friend;
}

- (void)qMaybeCreateAssociatedNameForFriend:(ToxFriend *)friend
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    if (friend.associatedName.length) {
        return;
    }

    if (! friend.realName) {
        return;
    }

    friend.associatedName = friend.realName;

    if (! friend.clientId) {
        return;
    }

    NSMutableDictionary *names = [NSMutableDictionary dictionaryWithDictionary:
        [UserInfoManager sharedInstance].uAssociatedNames];

    names[friend.clientId] = friend.realName;

    [UserInfoManager sharedInstance].uAssociatedNames = [names copy];
}

- (void)qIncomingMessage:(NSString *)message fromFriend:(ToxFriend *)friend
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    __weak ToxManager *weakSelf = self;

    [self qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
        [weakSelf qChatWithUser:user completionBlock:^(CDChat *chat) {
            // todo

            [weakSelf qAddMessage:message toChat:chat fromUser:user completionBlock:^(CDMessage *cdMessage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    EventObject *object = [EventObject objectWithType:EventObjectTypeChatMessage
                                                                image:nil
                                                               object:cdMessage];
                    [[EventsManager sharedInstance] addObject:object];

                    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [delegate updateBadgeForTab:AppDelegateTabIndexChats];
                });
            }];
        }];
    }];
}

- (void)qUserFromClientId:(NSString *)clientId completionBlock:(void (^)(CDUser *user))completionBlock
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientId == %@", clientId];

    [CoreDataManager getOrInsertUserWithPredicate:predicate configBlock:^(CDUser *u) {
        u.clientId = clientId;

    } completionQueue:self.queue completionBlock:completionBlock];
}

- (void)qChatWithUser:(CDUser *)user completionBlock:(void (^)(CDChat *chat))completionBlock
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"users.@count == 1 AND ANY users == %@", user];

    [CoreDataManager getOrInsertChatWithPredicate:predicate configBlock:^(CDChat *c) {
        [c addUsersObject:user];

    } completionQueue:self.queue completionBlock:completionBlock];
}

- (void)qAddMessage:(NSString *)message
             toChat:(CDChat *)chat
           fromUser:(CDUser *)user
    completionBlock:(void (^)(CDMessage *message))completionBlock
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    [CoreDataManager insertMessageWithConfigBlock:^(CDMessage *m) {
        m.text = message;
        m.date = [[NSDate date] timeIntervalSince1970];
        m.user = user;
        m.chat = chat;

        if (m.date > chat.lastMessage.date) {
            m.chatForLastMessageInverse = chat;
        }

    } completionQueue:self.queue completionBlock:completionBlock];
}

#pragma mark -  Private

@end

#pragma mark -  C functions

void friendRequestCallback(Tox *tox, const uint8_t * publicKey, const uint8_t * data, uint16_t length, void *userdata)
{
    NSLog(@"ToxManager: friendRequestCallback, publicKey %s", publicKey);

    NSString *key = [ToxFunctions publicKeyToString:(uint8_t *)publicKey];
    NSString *message = [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];

    ToxFriendRequest *request = [ToxFriendRequest friendRequestWithPublicKey:key message:message];

    [[ToxManager sharedInstance].friendsContainer private_addFriendRequest:request];

    EventObject *object = [EventObject objectWithType:EventObjectTypeFriendRequest
                                                image:nil
                                               object:request];
    [[EventsManager sharedInstance] addObject:object];

    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate updateBadgeForTab:AppDelegateTabIndexFriends];
    });
}

void friendMessageCallback(Tox *tox, int32_t friendnumber, const uint8_t *message, uint16_t length, void *userdata)
{
    NSLog(@"ToxManager: friendMessageCallback %d %s", friendnumber, message);

    NSString *messageString = [[NSString alloc] initWithBytes:message length:length encoding:NSUTF8StringEncoding];
    ToxFriend *friend = [[ToxManager sharedInstance].friendsContainer friendWithId:friendnumber];

    [[ToxManager sharedInstance] qIncomingMessage:messageString fromFriend:friend];
}

void nameChangeCallback(Tox *tox, int32_t friendnumber, const uint8_t *newname, uint16_t length, void *userdata)
{
    NSLog(@"ToxManager: nameChangeCallback %d %s", friendnumber, newname);

    [[ToxManager sharedInstance].friendsContainer private_updateFriendWithId:friendnumber updateBlock:^(ToxFriend *friend) {
        friend.realName = [NSString stringWithCString:(const char*)newname encoding:NSUTF8StringEncoding];

        [[ToxManager sharedInstance] qMaybeCreateAssociatedNameForFriend:friend];
    }];
}

void statusMessageCallback(Tox *tox, int32_t friendnumber, const uint8_t *newstatus, uint16_t length, void *userdata)
{
    NSLog(@"ToxManager: statusMessageCallback %d %s", friendnumber, newstatus);

    [[ToxManager sharedInstance].friendsContainer private_updateFriendWithId:friendnumber updateBlock:^(ToxFriend *friend) {
        friend.statusMessage = [NSString stringWithCString:(const char*)newstatus encoding:NSUTF8StringEncoding];
    }];
}

void userStatusCallback(Tox *tox, int32_t friendnumber, uint8_t status, void *userdata)
{
    NSLog(@"ToxManager: userStatusCallback %d %d", friendnumber, status);

    [[ToxManager sharedInstance].friendsContainer private_updateFriendWithId:friendnumber updateBlock:^(ToxFriend *friend) {
        if (status == TOX_USERSTATUS_NONE) {
            friend.status = ToxFriendStatusOnline;
        }
        else if (status == TOX_USERSTATUS_AWAY) {
            friend.status = ToxFriendStatusAway;
        }
        else if (status == TOX_USERSTATUS_BUSY) {
            friend.status = ToxFriendStatusBusy;
        }
        else if (status == TOX_USERSTATUS_INVALID) {
            friend.status = ToxFriendStatusOffline;
        }
    }];
}

void typingChangeCallback(Tox *tox, int32_t friendnumber, uint8_t isTyping, void *userdata)
{
    NSLog(@"ToxManager: typingChangeCallback %d %d", friendnumber, isTyping);

    [[ToxManager sharedInstance].friendsContainer private_updateFriendWithId:friendnumber updateBlock:^(ToxFriend *friend) {
        friend.isTyping = (isTyping == 1);
    }];
}

void readReceiptCallback(Tox *tox, int32_t friendnumber, uint32_t receipt, void *userdata)
{
    NSLog(@"ToxManager: readReceiptCallback %d %d", friendnumber, receipt);
}

void connectionStatusCallback(Tox *tox, int32_t friendnumber, uint8_t status, void *userdata)
{
    NSLog(@"ToxManager: connectionStatusCallback %d %d", friendnumber, status);

    [[ToxManager sharedInstance].friendsContainer private_updateFriendWithId:friendnumber updateBlock:^(ToxFriend *friend) {
        if (status == 0) {
            friend.status = ToxFriendStatusOffline;
        }
    }];

    [[ToxManager sharedInstance] qSaveTox];
}

