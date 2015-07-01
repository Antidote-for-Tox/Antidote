//
//  CallViewController.h
//  Antidote
//
//  Created by Chuong Vu on 7/1/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCTChat.h"

extern NSString *const kCallViewControllerUserIdentifier;

@interface CallViewController : UIViewController

@property (strong, nonatomic, readonly) OCTChat *chat;

- (instancetype)initWithChat:(OCTChat *)chat;

@end
