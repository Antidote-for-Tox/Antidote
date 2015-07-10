//
//  CallNavigationControllerViewController.h
//  Antidote
//
//  Created by Chuong Vu on 7/7/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OCTCall;
@class AbstractCallViewController;

/**
 * This class is used to hold all the AbstractCallViewControllers.
 */
@interface CallNavigationViewController : UINavigationController


/**
 * Ask the CallNavigationController to dismiss the current view and put on another call.
 * @call The call to switch to.
 * @viewController The View controller who made this request.
 */
- (void)switchToCall:(OCTCall *)call fromAbstractViewController:(AbstractCallViewController *)viewController;

@end
