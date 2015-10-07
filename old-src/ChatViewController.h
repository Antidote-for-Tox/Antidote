//
//  ChatViewController.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 10.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "JSQMessagesViewController.h"

#import "OCTChat.h"

extern NSString *const kChatViewControllerUserIdentifier;

@interface ChatViewController : JSQMessagesViewController

@property (strong, nonatomic, readonly) OCTChat *chat;

- (instancetype)initWithChat:(OCTChat *)chat;

@end
