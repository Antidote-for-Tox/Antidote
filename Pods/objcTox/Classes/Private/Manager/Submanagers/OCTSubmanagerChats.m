//
//  OCTSubmanagerChats.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 05.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTSubmanagerChats.h"
#import "OCTSubmanagerChats+Private.h"
#import "OCTArray+Private.h"
#import "OCTConverterChat.h"
#import "OCTDBManager.h"
#import "OCTChat+Private.h"

@interface OCTSubmanagerChats() <OCTConverterChatDelegate, OCTConverterFriendDataSource>

@property (weak, nonatomic) id<OCTSubmanagerDataSource> dataSource;

@property (strong, nonatomic) OCTConverterChat *converterChat;

@end

@implementation OCTSubmanagerChats

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    _converterChat = [OCTConverterChat new];
    _converterChat.delegate = self;

    _converterChat.converterFriend = [OCTConverterFriend new];
    _converterChat.converterFriend.dataSource = self;

    _converterChat.converterMessage = [OCTConverterMessage new];
    _converterChat.converterMessage.converterFriend = _converterChat.converterFriend;

    return self;
}

#pragma mark -  Public

- (OCTArray *)allChats
{
    RLMResults *results = [[self.dataSource managerGetDBManager] allChats];

    return [[OCTArray alloc] initWithRLMResults:results converter:self.converterChat];
}

- (OCTChat *)getOrCreateChatWithFriend:(OCTFriend *)friend
{
    NSParameterAssert(friend);
    OCTDBChat *db = [[self.dataSource managerGetDBManager] getOrCreateChatWithFriendNumber:friend.friendNumber];

    return (OCTChat *)[self.converterChat objectFromRLMObject:db];
}

- (OCTChat *)chatWithUniqueIdentifier:(NSString *)uniqueIdentifier
{
    NSParameterAssert(uniqueIdentifier);
    OCTDBChat *db = [[self.dataSource managerGetDBManager] chatWithUniqueIdentifier:uniqueIdentifier];

    return (OCTChat *)[self.converterChat objectFromRLMObject:db];
}

- (void)removeChatWithAllMessages:(OCTChat *)chat
{
    NSParameterAssert(chat);
    OCTDBChat *db = [[self.dataSource managerGetDBManager] chatWithUniqueIdentifier:chat.uniqueIdentifier];

    [[self.dataSource managerGetDBManager] removeChatWithAllMessages:db];
}

- (OCTArray *)allMessagesInChat:(OCTChat *)chat
{
    NSParameterAssert(chat);

    OCTDBManager *dbManager = [self.dataSource managerGetDBManager];

    OCTDBChat *db = [dbManager chatWithUniqueIdentifier:chat.uniqueIdentifier];
    RLMResults *results = [dbManager allMessagesInChat:db];

    return [[OCTArray alloc] initWithRLMResults:results converter:self.converterChat.converterMessage];
}

- (OCTMessageText *)sendMessageToChat:(OCTChat *)chat
                                 text:(NSString *)text
                                 type:(OCTToxMessageType)type
                                error:(NSError **)error
{
    NSParameterAssert(chat);
    NSParameterAssert(text);

    OCTTox *tox = [self.dataSource managerGetTox];
    OCTDBManager *dbManager = [self.dataSource managerGetDBManager];

    OCTFriend *friend = [chat.friends lastObject];

    OCTToxMessageId messageId = [tox sendMessageWithFriendNumber:friend.friendNumber type:type message:text error:error];

    if (messageId == 0) {
        return nil;
    }

    OCTDBChat *dbChat = [dbManager getOrCreateChatWithFriendNumber:friend.friendNumber];

    OCTDBMessageAbstract *db = [dbManager addMessageWithText:text type:type chat:dbChat sender:nil messageId:messageId];

    return (OCTMessageText *)[self.converterChat.converterMessage objectFromRLMObject:db];
}

- (BOOL)setIsTyping:(BOOL)isTyping inChat:(OCTChat *)chat error:(NSError **)error
{
    NSParameterAssert(chat);

    OCTFriend *friend = [chat.friends lastObject];
    OCTTox *tox = [self.dataSource managerGetTox];

    return [tox setUserIsTyping:isTyping forFriendNumber:friend.friendNumber error:error];
}

#pragma mark -  OCTConverterChatDelegate

- (void)converterChat:(OCTConverterChat *)converter updateDBChatWithBlock:(void (^)())block
{
    OCTDBManager *dbManager = [self.dataSource managerGetDBManager];

    [dbManager updateDBObjectInBlock:block objectClass:[OCTDBChat class]];
}

#pragma mark -  OCTConverterFriendDataSource

- (OCTTox *)converterFriendGetTox:(OCTConverterFriend *)converterFriend
{
    return [self.dataSource managerGetTox];
}

#pragma mark -  OCTToxDelegate

- (void)tox:(OCTTox *)tox friendMessage:(NSString *)message type:(OCTToxMessageType)type friendNumber:(OCTToxFriendNumber)friendNumber
{
    OCTDBManager *dbManager = [self.dataSource managerGetDBManager];

    OCTDBFriend *friend = [dbManager getOrCreateFriendWithFriendNumber:friendNumber];
    OCTDBChat *chat = [dbManager getOrCreateChatWithFriendNumber:friendNumber];

    [dbManager addMessageWithText:message type:type chat:chat sender:friend];
}

- (void)tox:(OCTTox *)tox messageDelivered:(OCTToxMessageId)messageId friendNumber:(OCTToxFriendNumber)friendNumber
{
    OCTDBManager *dbManager = [self.dataSource managerGetDBManager];

    OCTDBChat *chat = [dbManager getOrCreateChatWithFriendNumber:friendNumber];
    OCTDBMessageAbstract *message = [dbManager textMessageInChat:chat withMessageId:messageId];

    if (! message) {
        return;
    }

    [dbManager updateDBObjectInBlock:^{
        message.textMessage.isDelivered = YES;
    } objectClass:[OCTDBMessageAbstract class]];
}

@end
