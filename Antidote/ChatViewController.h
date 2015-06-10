//
//  ChatViewController.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 10.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "SLKTextViewController.h"

#import "OCTChat.h"

@interface ChatViewController : SLKTextViewController

@property (strong, nonatomic, readonly) OCTChat *chat;

- (instancetype)initWithChat:(OCTChat *)chat;

@end
