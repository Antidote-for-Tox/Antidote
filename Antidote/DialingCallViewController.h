//
//  DialingCallViewController.h
//  Antidote
//
//  Created by Chuong Vu on 7/1/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractCallViewController.h"

@class OCTSubmanagerCalls;
@class OCTChat;

/**
 * This class will be responsible for dialing a friend
 * through the user interface.
 */
@interface DialingCallViewController : AbstractCallViewController

- (instancetype)initWithChat:(OCTChat *)chat submanagerCalls:(OCTSubmanagerCalls *)manager;

- (instancetype)initWithCall:(OCTCall *)call submanagerCalls:(OCTSubmanagerCalls *)manager NS_UNAVAILABLE;

@end
