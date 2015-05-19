//
//  ChatViewController.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OCTChat.h"

@interface ChatViewController : UIViewController

@property (strong, nonatomic, readonly) OCTChat *chat;

- (instancetype)initWithChat:(OCTChat *)chat;

@end
