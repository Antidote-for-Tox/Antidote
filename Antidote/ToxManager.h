//
//  ToxManager.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 18.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ToxFriendsContainer.h"
#import "tox.h"
#import "CDChat.h"

@interface ToxManager : NSObject

@property (strong, nonatomic, readonly) ToxFriendsContainer *friendsContainer;

@property (strong, nonatomic, readonly) NSString *toxId;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userStatusMessage;

+ (instancetype)sharedInstance;

- (void)bootstrapWithAddress:(NSString *)address port:(NSUInteger)port publicKey:(NSString *)publicKey;

- (void)sendFriendRequestWithAddress:(NSString *)address message:(NSString *)message;
- (void)approveFriendRequest:(ToxFriendRequest *)request wasError:(BOOL *)wasError;

- (void)changeAssociatedNameTo:(NSString *)name forFriend:(ToxFriend *)friend;

- (void)changeIsTypingInChat:(CDChat *)chat to:(BOOL)isTyping;
- (void)sendMessage:(NSString *)message toChat:(CDChat *)chat;

- (CDChat *)chatWithToxFriend:(ToxFriend *)friend;

@end
