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

void friendRequestCallback(Tox *tox, const uint8_t * public_key, const uint8_t * data, uint16_t length, void *userdata);
void friendMessageCallback(Tox *tox, int32_t friendnumber, const uint8_t *message, uint16_t length, void *userdata);
void nameChangeCallback(Tox *tox, int32_t friendnumber, const uint8_t *newname, uint16_t length, void *userdata);
void statusMessageCallback(Tox *tox, int32_t friendnumber, const uint8_t *newstatus, uint16_t length, void *userdata);
void userStatusCallback(Tox *tox, int32_t friendnumber, uint8_t status, void *userdata);
void typingChangeCallback(Tox *tox, int32_t friendnumber, uint8_t isTyping, void *userdata);
void readReceiptCallback(Tox *tox, int32_t friendnumber, uint32_t receipt, void *userdata);
void connectionStatusCallback(Tox *tox, int32_t friendnumber, uint8_t status, void *userdata);

@interface ToxManager()

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
        [self createTox];

        [self loadFriendsAndCreateContainer];

        _queue = dispatch_queue_create("ToxManager queue", NULL);

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
    uint8_t *address = malloc(TOX_FRIEND_ADDRESS_SIZE);
    tox_get_address(self.tox, address);

    NSString *toxId = [ToxFunctions addressToString:address];

    free(address);

    return toxId;
}

- (NSString *)userName
{
    uint8_t *name = malloc(TOX_MAX_NAME_LENGTH);
    int size = tox_get_self_name(self.tox, name);

    NSString *userName = [[NSString alloc] initWithBytes:name length:size encoding:NSUTF8StringEncoding];

    free(name);

    return userName;
}

- (void)setUserName:(NSString *)userName
{
    NSString *oldUserName = self.userName;

    if (userName && oldUserName && [userName isEqualToString:oldUserName]) {
        return;
    }

    if (userName.length > TOX_MAX_NAME_LENGTH) {
        userName = [userName substringToIndex:TOX_MAX_NAME_LENGTH];
    }

    const char *name = [userName cStringUsingEncoding:NSUTF8StringEncoding];

    int result = tox_set_name(self.tox, (uint8_t *)name, userName.length);

    if (result == 0) {
        [self saveTox];
    }
}

- (NSString *)userStatusMessage
{
    int size = tox_get_self_status_message_size(self.tox);

    uint8_t *message = malloc(size);
    tox_get_self_status_message(self.tox, message, size);

    NSString *statusMessage = [[NSString alloc] initWithBytes:message length:size encoding:NSUTF8StringEncoding];

    free(message);

    return statusMessage;
}

- (void)setUserStatusMessage:(NSString *)statusMessage
{
    NSString *oldUserStatusMessage = self.userStatusMessage;

    if (statusMessage && oldUserStatusMessage && [statusMessage isEqualToString:oldUserStatusMessage]) {
        return;
    }

    if (statusMessage.length > TOX_MAX_STATUSMESSAGE_LENGTH) {
        statusMessage = [statusMessage substringToIndex:TOX_MAX_STATUSMESSAGE_LENGTH];
    }

    const char *message = [statusMessage cStringUsingEncoding:NSUTF8StringEncoding];

    int result = tox_set_status_message(self.tox, (uint8_t *)message, statusMessage.length);

    if (result == 0) {
        [self saveTox];
    }
}

#pragma mark -  Public

- (void)bootstrapWithAddress:(NSString *)address port:(NSUInteger)port publicKey:(NSString *)publicKey
{
    uint8_t *pub_key = [ToxFunctions hexStringToBin:publicKey];
    tox_bootstrap_from_address(self.tox, address.UTF8String, 1, htons(port), pub_key);
    free(pub_key);

    [self maybeStartTimer];
}

- (void)sendFriendRequestWithAddress:(NSString *)addressString message:(NSString *)messageString
{
    uint8_t *address = [ToxFunctions hexStringToBin:addressString];
    const char *message = NULL;

    if (messageString) {
        message = [messageString cStringUsingEncoding:NSUTF8StringEncoding];
    }

    int32_t result = tox_add_friend(self.tox, address, (const uint8_t *)message, messageString.length);

    free(address);

    if (result > -1) {
        [self saveTox];

        [self.friendsContainer private_addFriend:[self createFriendWithId:result]];
    }
    else {

    }
}

- (void)approveFriendRequest:(ToxFriendRequest *)request wasError:(BOOL *)wasError
{
    uint8_t *clientId = [ToxFunctions hexStringToBin:request.clientId];
    uint32_t friendId = tox_add_friend_norequest(self.tox, clientId);
    free(clientId);

    if (friendId == -1) {
        if (wasError) {
            *wasError = YES;
        }
    }
    else {
        [self saveTox];

        [self.friendsContainer private_removeFriendRequest:request];
        [self.friendsContainer private_addFriend:[self createFriendWithId:friendId]];
    }
}

- (void)changeAssociatedNameTo:(NSString *)name forFriend:(ToxFriend *)friendToChange
{
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
            [[ToxManager sharedInstance] maybeCreateAssociatedNameForFriend:friend];
        }
    }];
}

- (void)changeIsTypingInChat:(CDChat *)chat to:(BOOL)isTyping
{
    if (! chat) {
        return;
    }

    CDUser *user = [chat.users anyObject];
    ToxFriend *friend = [self.friendsContainer friendWithClientId:user.clientId];

    uint8_t typing = isTyping ? 1 : 0;
    tox_set_user_is_typing(self.tox, friend.id, typing);
}

- (void)sendMessage:(NSString *)message toChat:(CDChat *)chat
{
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

    CDUser *currentUser = [self userFromClientId:[self toxId]];
    [self addMessage:message toChat:chat fromUser:currentUser];
}

- (CDChat *)chatWithToxFriend:(ToxFriend *)friend
{
    CDUser *user = [self userFromClientId:friend.clientId];
    return [self chatWithUser:user];
}

#pragma mark -  Notifications

- (void)applicationWillTerminateNotification:(NSNotification *)notification
{
    [self saveTox];
    tox_kill(self.tox);
}

#pragma mark -  Private

- (void)createTox
{
    NSLog(@"ToxManager: creating tox");
    _tox = tox_new(TOX_ENABLE_IPV6_DEFAULT);

    NSData *toxData = [UserInfoManager sharedInstance].uToxData;

    if (toxData) {
        NSLog(@"ToxManager: old data found, loading...");
        tox_load(_tox, (uint8_t *)toxData.bytes, toxData.length);
    }
    else {
        [self saveTox];
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

- (void)loadFriendsAndCreateContainer
{
    uint32_t friendsCount = tox_count_friendlist(self.tox);
    uint32_t listSize = friendsCount * sizeof(int32_t);

    int32_t *friendsList = malloc(listSize);

    tox_get_friendlist(self.tox, friendsList, listSize);

    NSMutableArray *friendsArray = [NSMutableArray new];

    for (NSUInteger index = 0; index < friendsCount; index++) {
        int32_t friendId = friendsList[index];

        [friendsArray addObject:[self createFriendWithId:friendId]];
    }

    _friendsContainer = [[ToxFriendsContainer alloc] initWithFriendsArray:[friendsArray copy]];

    free(friendsList);
}

- (void)saveTox
{
    @synchronized(self) {
        uint32_t size = tox_size(_tox);
        uint8_t *data = malloc(size);

        tox_save(_tox, data);

        [UserInfoManager sharedInstance].uToxData = [NSData dataWithBytes:data length:size];

        free(data);
    }
}

- (void)maybeStartTimer
{
    if (self.timer) {
        return;
    }

    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);

    [self updateTimerInterval:tox_do_interval(self.tox)];

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
            [weakSelf updateTimerInterval:newInterval];
        }
    });
    dispatch_resume(self.timer);
}

- (void)updateTimerInterval:(uint32_t)newInterval
{
    self.timerMillisecondsUpdateInterval = newInterval;

    uint64_t actualInterval = newInterval * (NSEC_PER_SEC / 1000);

    dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), actualInterval, actualInterval / 5);
}

- (ToxFriend *)createFriendWithId:(int32_t)friendId
{
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

    friend.isTyping = tox_get_is_typing(self.tox, friendId);

    {
        if (friend.clientId) {
            NSDictionary *names = [UserInfoManager sharedInstance].uAssociatedNames;

            friend.associatedName = names[friend.clientId];
        }
    }

    [self maybeCreateAssociatedNameForFriend:friend];

    return friend;
}

- (void)maybeCreateAssociatedNameForFriend:(ToxFriend *)friend
{
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

- (void)incomingMessage:(NSString *)message fromFriend:(ToxFriend *)friend
{
    CDUser *user = [self userFromClientId:friend.clientId];
    CDChat *chat = [self chatWithUser:user];

    [self addMessage:message toChat:chat fromUser:user];
}

- (CDUser *)userFromClientId:(NSString *)clientId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientId == %@", clientId];

    return [CoreDataManager getOrInsertUserWithPredicate:predicate configBlock:^(CDUser *u) {
        u.clientId = clientId;
    }];
}

- (CDChat *)chatWithUser:(CDUser *)user
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"users.@count == 1 AND ANY users == %@", user];

    return [CoreDataManager getOrInsertChatWithPredicate:predicate configBlock:^(CDChat *c) {
        [c addUsersObject:user];
    }];
}

- (void)addMessage:(NSString *)message toChat:(CDChat *)chat fromUser:(CDUser *)user
{
    [CoreDataManager insertMessageWithConfigBlock:^(CDMessage *m) {
        m.text = message;
        m.date = [[NSDate date] timeIntervalSince1970];
        m.user = user;
        m.chat = chat;

        if (m.date > chat.lastMessage.date) {
            m.chatForLastMessageInverse = chat;
        }
    }];
}

@end

#pragma mark -  C functions

void friendRequestCallback(Tox *tox, const uint8_t * publicKey, const uint8_t * data, uint16_t length, void *userdata)
{
    NSLog(@"ToxManager: friendRequestCallback, publicKey %s", publicKey);

    NSString *key = [ToxFunctions publicKeyToString:(uint8_t *)publicKey];
    NSString *message = [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];

    ToxFriendRequest *request = [ToxFriendRequest friendRequestWithPublicKey:key message:message];

    [[ToxManager sharedInstance].friendsContainer private_addFriendRequest:request];
}

void friendMessageCallback(Tox *tox, int32_t friendnumber, const uint8_t *message, uint16_t length, void *userdata)
{
    NSLog(@"ToxManager: friendMessageCallback %d %s", friendnumber, message);

    NSString *messageString = [[NSString alloc] initWithBytes:message length:length encoding:NSUTF8StringEncoding];
    ToxFriend *friend = [[ToxManager sharedInstance].friendsContainer friendWithId:friendnumber];

    [[ToxManager sharedInstance] incomingMessage:messageString fromFriend:friend];
}

void nameChangeCallback(Tox *tox, int32_t friendnumber, const uint8_t *newname, uint16_t length, void *userdata)
{
    NSLog(@"ToxManager: nameChangeCallback %d %s", friendnumber, newname);

    [[ToxManager sharedInstance].friendsContainer private_updateFriendWithId:friendnumber updateBlock:^(ToxFriend *friend) {
        friend.realName = [NSString stringWithCString:(const char*)newname encoding:NSUTF8StringEncoding];

        [[ToxManager sharedInstance] maybeCreateAssociatedNameForFriend:friend];
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
}

