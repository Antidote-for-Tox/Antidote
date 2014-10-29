//
//  ToxManagerChats.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 23.10.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxManagerChats.h"
#import "ToxManager+Private.h"
#import "ToxManager+Private.h"
#import "CoreDataManager+User.h"
#import "CoreDataManager+Chat.h"
#import "CoreDataManager+Message.h"
#import "EventsManager.h"
#import "AppDelegate.h"

void friendMessageCallback(Tox *tox, int32_t friendnumber, const uint8_t *message, uint16_t length, void *userdata);
void readReceiptCallback(Tox *tox, int32_t friendnumber, uint32_t receipt, void *userdata);

@implementation ToxManagerChats

#pragma mark -  Public

- (instancetype)initOnToxQueue
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    self = [super init];

    if (! self) {
        return nil;
    }

    DDLogInfo(@"ToxManagerChats: registering callbacks");

    tox_callback_friend_message ([ToxManager sharedInstance].tox, friendMessageCallback, NULL);
    tox_callback_read_receipt   ([ToxManager sharedInstance].tox, readReceiptCallback,   NULL);

    return self;
}

- (void)qChangeIsTypingInChat:(CDChat *)chat to:(BOOL)isTyping
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    if (! chat) {
        return;
    }

    CDUser *user = [chat.users anyObject];
    ToxFriend *friend = [[ToxManager sharedInstance].friendsContainer friendWithClientId:user.clientId];

    uint8_t typing = isTyping ? 1 : 0;
    tox_set_user_is_typing([ToxManager sharedInstance].tox, friend.id, typing);
}

- (void)qSendMessage:(NSString *)message toChat:(CDChat *)chat
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManagerChats: send message with length %lu to chat %@...", (unsigned long)message.length, chat);

    if (! message.length || ! chat) {
        DDLogError(@"ToxManagerChats: send message... empty message or no chat");

        return;
    }

    if (chat.users.count > 1) {
        DDLogError(@"ToxManagerChats: send message... group chats aren't supported yet");
        return;
    }

    CDUser *user = [chat.users anyObject];

    ToxFriend *friend = [[ToxManager sharedInstance].friendsContainer friendWithClientId:user.clientId];

    const char *cMessage = [message cStringUsingEncoding:NSUTF8StringEncoding];

    uint32_t messageId = tox_send_message(
            [ToxManager sharedInstance].tox,
            friend.id,
            (uint8_t *)cMessage,
            (uint32_t)[message lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);

    __weak ToxManagerChats *weakSelf = self;

    [self qUserFromClientId:[[ToxManager sharedInstance] qClientId] completionBlock:^(CDUser *currentUser) {
        [weakSelf qAddMessage:message messageId:messageId toChat:chat fromUser:currentUser completionBlock:nil];
    }];

    DDLogInfo(@"ToxManagerChats: send message... success");
}

- (void)qChatWithToxFriend:(ToxFriend *)friend completionBlock:(void (^)(CDChat *chat))completionBlock
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    __weak ToxManagerChats *weakSelf = self;

    [self qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {

        [weakSelf qChatWithUser:user completionBlock:completionBlock];
    }];
}

- (void)qUserFromClientId:(NSString *)clientId completionBlock:(void (^)(CDUser *user))completionBlock
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientId == %@", clientId];

    [CoreDataManager getOrInsertUserWithPredicateInCurrentProfile:predicate configBlock:^(CDUser *u) {
        u.clientId = clientId;

    } completionQueue:[ToxManager sharedInstance].queue completionBlock:completionBlock];
}

- (void)qChatWithUser:(CDUser *)user completionBlock:(void (^)(CDChat *chat))completionBlock
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"users.@count == 1 AND ANY users == %@", user];

    [CoreDataManager getOrInsertChatWithPredicateInCurrentProfile:predicate configBlock:^(CDChat *c) {
        [c addUsersObject:user];

    } completionQueue:[ToxManager sharedInstance].queue completionBlock:completionBlock];
}

#pragma mark -  Private

- (void)qIncomingMessage:(NSString *)message fromFriend:(ToxFriend *)friend
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManagerChats: incoming message with length %lu from friend id %d",
            (unsigned long)message.length, friend.id);

    __weak ToxManagerChats *weakSelf = self;

    [self qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
        [weakSelf qChatWithUser:user completionBlock:^(CDChat *chat) {
            [weakSelf qAddMessage:message messageId:0 toChat:chat fromUser:user completionBlock:^(CDMessage *cdMessage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    EventObject *object = [EventObject objectWithType:EventObjectTypeChatIncomingMessage
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


- (void)qReadReceipt:(uint32_t)receipt fromFriend:(ToxFriend *)friend
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    __weak ToxManagerChats *weakSelf = self;

    [self qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
        [weakSelf qChatWithUser:user completionBlock:^(CDChat *chat) {

            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chat == %@ AND text.id == %d",
                chat, receipt];

            [CoreDataManager messagesWithPredicate:predicate completionQueue:[ToxManager sharedInstance].queue
                                   completionBlock:^(NSArray *array)
            {
                CDMessage *message = [array lastObject];

                if (! message.text) {
                    return;
                }

                [CoreDataManager editCDMessageAndSendNotificationsWithMessage:message block:^{
                    message.text.isDelivered = YES;
                } completionQueue:nil completionBlock:nil];
            }];
        }];
    }];
}

- (void)qAddMessage:(NSString *)message
          messageId:(uint32_t)messageId
             toChat:(CDChat *)chat
           fromUser:(CDUser *)user
    completionBlock:(void (^)(CDMessage *message))completionBlock
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManagerChats: adding message to CoreData");

    [CoreDataManager insertMessageWithType:CDMessageTypeText configBlock:^(CDMessage *m) {
        m.text.id = messageId;
        m.text.text = message;
        m.date = [[NSDate date] timeIntervalSince1970];
        m.user = user;
        m.chat = chat;

        if (m.date > chat.lastMessage.date) {
            m.chatForLastMessageInverse = chat;
        }

    } completionQueue:[ToxManager sharedInstance].queue completionBlock:completionBlock];
}

@end

#pragma mark -  C functions

void friendMessageCallback(Tox *tox, int32_t friendnumber, const uint8_t *message, uint16_t length, void *userdata)
{
    DDLogCVerbose(@"ToxManagerChats: friendMessageCallback with friendnumber %d", friendnumber);

    NSString *messageString = [[NSString alloc] initWithBytes:message length:length encoding:NSUTF8StringEncoding];
    ToxFriend *friend = [[ToxManager sharedInstance].friendsContainer friendWithId:friendnumber];

    dispatch_async([ToxManager sharedInstance].queue, ^{
        [[ToxManager sharedInstance].managerChats qIncomingMessage:messageString fromFriend:friend];
    });
}

void readReceiptCallback(Tox *tox, int32_t friendnumber, uint32_t receipt, void *userdata)
{
    DDLogCVerbose(@"ToxManagerChats: readReceiptCallback with friendnumber %d receipt %d", friendnumber, receipt);

    ToxFriend *friend = [[ToxManager sharedInstance].friendsContainer friendWithId:friendnumber];

    dispatch_async([ToxManager sharedInstance].queue, ^{
        [[ToxManager sharedInstance].managerChats qReadReceipt:receipt fromFriend:friend];
    });
}

