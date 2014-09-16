//
//  ToxManager.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 18.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "tox.h"
#import "ToxFriendsContainer.h"
#import "ToxManagerFileProgressDelegate.h"
#import "ToxNode.h"
#import "CDChat.h"
#import "CDMessage.h"

@interface ToxManager : NSObject

@property (weak, nonatomic) id <ToxManagerFileProgressDelegate> fileProgressDelegate;

@property (strong, nonatomic, readonly) ToxFriendsContainer *friendsContainer;

@property (strong, nonatomic, readonly) NSString *toxId;
@property (strong, nonatomic, readonly) NSString *clientId;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userStatusMessage;

+ (instancetype)sharedInstance;
- (void)killSharedInstance;

- (void)bootstrapWithNodes:(NSArray *)nodes;

- (void)sendFriendRequestWithAddress:(NSString *)address message:(NSString *)message;
- (void)approveFriendRequest:(ToxFriendRequest *)request withBlock:(void (^)(BOOL wasError))block;
- (void)removeFriendRequest:(ToxFriendRequest *)request;
- (void)removeFriend:(ToxFriend *)friend;

- (void)changeNicknameTo:(NSString *)name forFriend:(ToxFriend *)friend;

- (void)changeIsTypingInChat:(CDChat *)chat to:(BOOL)isTyping;
- (void)sendMessage:(NSString *)message toChat:(CDChat *)chat;

- (void)chatWithToxFriend:(ToxFriend *)friend completionBlock:(void (^)(CDChat *chat))completionBlock;

- (void)acceptOrRefusePendingFileInMessage:(CDMessage *)message accept:(BOOL)accept;
- (CGFloat)progressForPendingFileInMessage:(CDMessage *)message;
- (void)togglePauseForPendingFileInMessage:(CDMessage *)message;

@end
