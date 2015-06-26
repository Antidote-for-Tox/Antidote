//
//  ChatMessage.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 26.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ChatMessage.h"
#import "OCTMessageText.h"
#import "OCTMessageFile.h"
#import "OCTFriend.h"
#import "ChatViewController.h"

@interface ChatMessage ()

@property (strong, nonatomic) OCTMessageAbstract *message;

@end

@implementation ChatMessage

#pragma mark -  Lifecycle

- (instancetype)initWithMessage:(OCTMessageAbstract *)message
{
    self = [super init];

    if (! self) {
        return nil;
    }

    _message = message;

    return self;
}

#pragma mark -  JSQMessageData

- (NSString *)senderId
{
    if (self.message.sender) {
        return self.message.sender.uniqueIdentifier;
    }

    return kChatViewControllerUserIdentifier;
}

- (NSString *)senderDisplayName
{
    if (self.message.sender) {
        return self.message.sender.nickname;
    }

    return kChatViewControllerUserIdentifier;
}

- (NSDate *)date
{
    return [self.message date];
}

- (BOOL)isMediaMessage
{
    // no file transfers yet
    return NO;
    // return (self.message.messageFile != nil);
}

- (NSUInteger)messageHash
{
    return [self.message hash];
}

- (NSString *)text
{
    return self.message.messageText.text;
}

@end
