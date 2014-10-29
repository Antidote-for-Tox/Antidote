//
//  ToxManagerChats.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 23.10.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ToxManager.h"

@interface ToxManagerChats : NSObject

- (instancetype)initOnToxQueue;

- (void)qChangeIsTypingInChat:(CDChat *)chat to:(BOOL)isTyping;
- (void)qSendMessage:(NSString *)message toChat:(CDChat *)chat;
- (void)qChatWithToxFriend:(ToxFriend *)friend completionBlock:(void (^)(CDChat *chat))completionBlock;
- (void)qUserFromClientId:(NSString *)clientId completionBlock:(void (^)(CDUser *user))completionBlock;
- (void)qChatWithUser:(CDUser *)user completionBlock:(void (^)(CDChat *chat))completionBlock;

@end
