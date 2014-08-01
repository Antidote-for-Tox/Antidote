//
//  ChatViewController.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CDChat.h"

@interface ChatViewController : UIViewController

@property (strong, nonatomic, readonly) CDChat *chat;

- (instancetype)initWithChat:(CDChat *)chat;

@end
