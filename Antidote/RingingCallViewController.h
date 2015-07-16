//
//  RingingCallViewController.h
//  Antidote
//
//  Created by Chuong Vu on 7/2/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AbstractCallViewController.h"

@class RingingCallViewController;
/**
 * Use this controller whenever an incoming call occurs
 */

@protocol RingingCallViewControllerDelegate <NSObject>

- (void)ringingCallAnswerButtonPressed:(RingingCallViewController *)controller;
- (void)ringingCallDeclineButtonPressed:(RingingCallViewController *)controller;

@end

@interface RingingCallViewController : AbstractCallViewController

@property (weak, nonatomic) id<RingingCallViewControllerDelegate> delegate;

@end
