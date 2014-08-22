//
//  ToxManager+PrivateChat.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 15.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxManager+PrivateChat.h"
#import "ToxManager+Private.h"
#import "ToxManager+Private.h"
#import "CoreDataManager+User.h"
#import "CoreDataManager+Chat.h"
#import "CoreDataManager+Message.h"
#import "EventsManager.h"
#import "AppDelegate.h"

void friendMessageCallback(Tox *tox, int32_t friendnumber, const uint8_t *message, uint16_t length, void *userdata);
void readReceiptCallback(Tox *tox, int32_t friendnumber, uint32_t receipt, void *userdata);

@implementation ToxManager (PrivateChat)

#pragma mark -  Public

- (void)qRegisterChatsCallbacks
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager: registering callbacks");

    tox_callback_friend_message (self.tox, friendMessageCallback, NULL);
    tox_callback_read_receipt   (self.tox, readReceiptCallback,   NULL);
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

    DDLogInfo(@"ToxManager: send message with length %lu to chat %@...", message.length, chat);

    if (! message.length || ! chat) {
        DDLogError(@"ToxManager: send message... empty message or no chat");

        return;
    }

    if (chat.users.count > 1) {
        DDLogError(@"ToxManager: send message... group chats aren't supported yet");
        return;
    }

    CDUser *user = [chat.users anyObject];

    ToxFriend *friend = [self.friendsContainer friendWithClientId:user.clientId];

    const char *cMessage = [message cStringUsingEncoding:NSUTF8StringEncoding];

    tox_send_message(
            self.tox,
            friend.id,
            (uint8_t *)cMessage,
            (uint32_t)[message lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);

    __weak ToxManager *weakSelf = self;

    [self qUserFromClientId:[self qClientId] completionBlock:^(CDUser *currentUser) {
        [weakSelf qAddMessage:message toChat:chat fromUser:currentUser completionBlock:nil];
    }];

    DDLogInfo(@"ToxManager: send message... success");
}

- (void)qChatWithToxFriend:(ToxFriend *)friend completionBlock:(void (^)(CDChat *chat))completionBlock
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    __weak ToxManager *weakSelf = self;

    [self qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {

        [weakSelf qChatWithUser:user completionBlock:completionBlock];
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

#pragma mark -  Private

- (void)qIncomingMessage:(NSString *)message fromFriend:(ToxFriend *)friend
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager: incoming message with length %lu from friend id %d", (unsigned long)message.length, friend.id);

    __weak ToxManager *weakSelf = self;

    [self qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
        [weakSelf qChatWithUser:user completionBlock:^(CDChat *chat) {
            [weakSelf qAddMessage:message toChat:chat fromUser:user completionBlock:^(CDMessage *cdMessage) {
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

- (void)qAddMessage:(NSString *)message
             toChat:(CDChat *)chat
           fromUser:(CDUser *)user
    completionBlock:(void (^)(CDMessage *message))completionBlock
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager: adding message to CoreData");

    [CoreDataManager insertMessageWithType:CDMessageTypeText configBlock:^(CDMessage *m) {
        m.text.text = message;
        m.date = [[NSDate date] timeIntervalSince1970];
        m.user = user;
        m.chat = chat;

        if (m.date > chat.lastMessage.date) {
            m.chatForLastMessageInverse = chat;
        }

    } completionQueue:self.queue completionBlock:completionBlock];
}

@end

#pragma mark -  C functions

void friendMessageCallback(Tox *tox, int32_t friendnumber, const uint8_t *message, uint16_t length, void *userdata)
{
    DDLogCVerbose(@"ToxManager+PrivateChat: friendMessageCallback with friendnumber %d", friendnumber);

    NSString *messageString = [[NSString alloc] initWithBytes:message length:length encoding:NSUTF8StringEncoding];
    ToxFriend *friend = [[ToxManager sharedInstance].friendsContainer friendWithId:friendnumber];

    dispatch_async([ToxManager sharedInstance].queue, ^{
        [[ToxManager sharedInstance] qIncomingMessage:messageString fromFriend:friend];
    });
}

void readReceiptCallback(Tox *tox, int32_t friendnumber, uint32_t receipt, void *userdata)
{
    DDLogCVerbose(@"ToxManager+PrivateChat: readReceiptCallback with friendnumber %d receipt %d", friendnumber, receipt);

    // dispatch_async([ToxManager sharedInstance].queue, ^{
    // });
}

