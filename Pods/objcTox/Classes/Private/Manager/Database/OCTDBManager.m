//
//  OCTDBManager.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 19.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Realm/Realm.h>

#import "OCTDBManager.h"

NSString *const kOCTDBManagerUpdateNotification = @"kOCTDBManagerUpdateNotification";
NSString *const kOCTDBManagerObjectClassKey = @"kOCTDBManagerObjectClassKey";

@interface OCTDBManager()

@property (strong, nonatomic) dispatch_queue_t queue;
@property (strong, nonatomic) RLMRealm *realm;

@end

@implementation OCTDBManager

#pragma mark -  Lifecycle

- (instancetype)initWithDatabasePath:(NSString *)path
{
    NSParameterAssert(path);

    self = [super init];

    if (! self) {
        return nil;
    }

    _queue = dispatch_queue_create("OCTDBManager queue", NULL);

    dispatch_sync(_queue, ^{
        _realm = [RLMRealm realmWithPath:path];
    });

    return self;
}

#pragma mark -  Public

- (NSString *)path
{
    return self.realm.path;
}

- (void)updateDBObjectInBlock:(void (^)())updateBlock objectClass:(Class)class
{
    NSParameterAssert(updateBlock);
    NSParameterAssert(class);

    dispatch_sync(self.queue, ^{
        [self.realm beginWriteTransaction];
        updateBlock();
        [self.realm commitWriteTransaction];

        [self sendUpdateNotificationForClass:class];
    });
}

#pragma mark -  Friend requests

- (RLMResults *)allFriendRequests
{
    __block RLMResults *results = nil;

    dispatch_sync(self.queue, ^{
        results = [OCTDBFriendRequest allObjectsInRealm:self.realm];
    });

    return results;
}

- (void)addFriendRequest:(OCTDBFriendRequest *)friendRequest
{
    NSParameterAssert(friendRequest.publicKey);

    dispatch_sync(self.queue, ^{
        [self.realm beginWriteTransaction];
        [self.realm addObject:friendRequest];
        [self.realm commitWriteTransaction];

        [self sendUpdateNotificationForClass:[OCTDBFriendRequest class]];
    });
}

- (void)removeFriendRequestWithPublicKey:(NSString *)publicKey
{
    NSParameterAssert(publicKey);

    dispatch_sync(self.queue, ^{
        OCTDBFriendRequest *db = [OCTDBFriendRequest objectInRealm:self.realm forPrimaryKey:publicKey];

        if (! db) {
            return;
        }

        [self.realm beginWriteTransaction];
        [self.realm deleteObject:db];
        [self.realm commitWriteTransaction];

        [self sendUpdateNotificationForClass:[OCTDBFriendRequest class]];
    });
}

#pragma mark -  Friends

- (OCTDBFriend *)getOrCreateFriendWithFriendNumber:(NSInteger)friendNumber
{
    __block OCTDBFriend *friend;

    dispatch_sync(self.queue, ^{
        friend = [OCTDBFriend objectInRealm:self.realm forPrimaryKey:@(friend.friendNumber)];

        if (friend) {
            return;
        }

        friend = [OCTDBFriend new];
        friend.friendNumber = friendNumber;

        [self.realm beginWriteTransaction];
        friend = [OCTDBFriend createOrUpdateInRealm:self.realm withValue:friend];
        [self.realm commitWriteTransaction];

        [self sendUpdateNotificationForClass:[OCTDBFriend class]];
    });

    return friend;
}

#pragma mark -  Chats

- (RLMResults *)allChats
{
    __block RLMResults *results;

    dispatch_sync(self.queue, ^{
        results = [OCTDBChat allObjectsInRealm:self.realm];
    });

    return results;
}

- (OCTDBChat *)getOrCreateChatWithFriendNumber:(NSInteger)friendNumber
{
    OCTDBFriend *friend = [self getOrCreateFriendWithFriendNumber:friendNumber];

    __block OCTDBChat *chat = nil;

    dispatch_sync(self.queue, ^{
        // TODO add this (friends.@count == 1) condition. Currentry Realm doesn't support collection queries
        // See https://github.com/realm/realm-cocoa/issues/1490
        // chat = [[OCTDBChat objectsInRealm:self.realm
        //                             where:@"friends.@count == 1 AND ANY friends == %@", friend] lastObject];

        chat = [[OCTDBChat objectsInRealm:self.realm where:@"ANY friends == %@", friend] lastObject];

        if ( chat) {
            return;
        }

        chat = [OCTDBChat new];
        chat.lastMessage = nil;

        [self.realm beginWriteTransaction];
        [self.realm addObject:chat];
        [chat.friends addObject:friend];
        [self.realm commitWriteTransaction];

        [self sendUpdateNotificationForClass:[OCTDBChat class]];
    });

    return chat;
}

- (OCTDBChat *)chatWithUniqueIdentifier:(NSString *)uniqueIdentifier
{
    __block OCTDBChat *chat = nil;

    dispatch_sync(self.queue, ^{
        chat = [OCTDBChat objectInRealm:self.realm forPrimaryKey:uniqueIdentifier];
    });

    return chat;
}

- (void)removeChatWithAllMessages:(OCTDBChat *)chat
{
    NSParameterAssert(chat);

    dispatch_sync(self.queue, ^{
        RLMResults *messages = [OCTDBMessageAbstract objectsInRealm:self.realm where:@"chat == %@", chat];

        [self.realm beginWriteTransaction];
        for (OCTDBMessageAbstract *message in messages) {
            if (message.textMessage) {
                [self.realm deleteObject:message.textMessage];
            }
            if (message.fileMessage) {
                [self.realm deleteObject:message.fileMessage];
            }
        }

        [self.realm deleteObjects:messages];
        [self.realm deleteObject:chat];
        [self.realm commitWriteTransaction];

        [self sendUpdateNotificationForClass:[OCTDBChat class]];
        [self sendUpdateNotificationForClass:[OCTDBMessageAbstract class]];
    });
}

#pragma mark -  Messages

- (RLMResults *)allMessagesInChat:(OCTDBChat *)chat
{
    NSParameterAssert(chat);

    __block RLMResults *results;

    dispatch_sync(self.queue, ^{
        results = [OCTDBMessageAbstract objectsInRealm:self.realm where:@"chat == %@", chat];
    });

    return results;
}

- (OCTDBMessageAbstract *)addMessageWithText:(NSString *)text
                                        type:(OCTToxMessageType)type
                                        chat:(OCTDBChat *)chat
                                      sender:(OCTDBFriend *)sender
{
    return [self addMessageWithText:text type:type chat:chat sender:sender messageId:0];
}

- (OCTDBMessageAbstract *)addMessageWithText:(NSString *)text
                                        type:(OCTToxMessageType)type
                                        chat:(OCTDBChat *)chat
                                      sender:(OCTDBFriend *)sender
                                   messageId:(int)messageId
{
    __block OCTDBMessageAbstract *message;

    dispatch_sync(self.queue, ^{
        message = [OCTDBMessageAbstract new];
        message.dateInterval = [[NSDate date] timeIntervalSince1970];
        message.sender = sender;
        message.chat = chat;
        message.textMessage = [OCTDBMessageText new];
        message.textMessage.text = text;
        message.textMessage.isDelivered = NO;
        message.textMessage.type = type;
        message.textMessage.messageId = messageId;

        [self.realm beginWriteTransaction];
        [self.realm addObject:message];
        [self.realm commitWriteTransaction];

        [self sendUpdateNotificationForClass:[OCTDBMessageAbstract class]];
    });

    return message;
}

- (OCTDBMessageAbstract *)textMessageInChat:(OCTDBChat *)chat withMessageId:(int)messageId
{
    NSParameterAssert(chat);
    NSAssert(messageId > 0, @"messageId should be positive");

    __block OCTDBMessageAbstract *message;

    dispatch_sync(self.queue, ^{
        RLMResults *objects = [OCTDBMessageAbstract objectsInRealm:self.realm where:
            @"chat == %@ AND textMessage.messageId == %d", chat, messageId];

        if (objects.count) {
            message = [objects firstObject];
        }
    });

    return message;
}

#pragma mark -  Private

- (void)sendUpdateNotificationForClass:(Class)class
{
    NSParameterAssert(class);

    void (^block)() = ^() {
        [[NSNotificationCenter defaultCenter] postNotificationName:kOCTDBManagerUpdateNotification
                                                            object:nil
                                                          userInfo:@{ kOCTDBManagerObjectClassKey : class }];
    };

    [NSThread isMainThread] ? block() : dispatch_async(dispatch_get_main_queue(), block);
}

@end
