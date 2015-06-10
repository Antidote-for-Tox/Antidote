//
//  ChatViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 10.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@property (strong, nonatomic, readwrite) OCTChat *chat;

@end

@implementation ChatViewController

#pragma mark -  Lifecycle

- (instancetype)initWithChat:(OCTChat *)chat
{
    self = [super init];

    if (! self) {
        return nil;
    }

    self.chat = chat;

    return self;
}

@end
