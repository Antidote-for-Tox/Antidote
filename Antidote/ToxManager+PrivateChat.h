//
//  ToxManager+PrivateChat.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 15.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxManager.h"

@interface ToxManager (PrivateChat)

- (void)qRegisterChatsCallbacks;

- (void)qChangeIsTypingInChat:(CDChat *)chat to:(BOOL)isTyping;
- (void)qSendMessage:(NSString *)message toChat:(CDChat *)chat;
- (void)qChatWithToxFriend:(ToxFriend *)friend completionBlock:(void (^)(CDChat *chat))completionBlock;
- (void)qUserFromClientId:(NSString *)clientId completionBlock:(void (^)(CDUser *user))completionBlock;
- (void)qChatWithUser:(CDUser *)user completionBlock:(void (^)(CDChat *chat))completionBlock;

@end

