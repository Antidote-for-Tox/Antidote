//
//  DialingCallViewController.h
//  Antidote
//
//  Created by Chuong Vu on 7/1/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OCTSubmanagerCalls;
@class OCTChat;

/**
 * This call viewcontroller will be responsible for handling calls
 * through the user interface. This will be used for presenting the incoming call
 * and active call sessions.
 */
@interface DialingCallViewController : UIViewController

@property (strong, nonatomic, readonly) OCTChat *chat;

/**
 * Create an instance of the CallViewController
 * @param chat Appropriate chat for the call.
 * @param manager The call maanger for the application.
 */
- (instancetype)initWithChat:(OCTChat *)chat submanagerCalls:(OCTSubmanagerCalls *)manager;

@end
