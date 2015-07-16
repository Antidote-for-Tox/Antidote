//
//  DialingCallViewController.h
//  Antidote
//
//  Created by Chuong Vu on 7/1/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractCallViewController.h"

@class DialingCallViewController;
/**
 * This class will be responsible for dialing a friend
 * through the user interface.
 */

@protocol DialingCallViewControllerDelegate <NSObject>

- (void)dialingCallDeclineButtonPressed:(DialingCallViewController *)controller;

@end

@interface DialingCallViewController : AbstractCallViewController

@property (weak, nonatomic) id<DialingCallViewControllerDelegate> delegate;

@end
