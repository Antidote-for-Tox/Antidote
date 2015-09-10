//
//  KeyboardNotificationController.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 10/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyboardNotificationController : UIViewController

/**
 * Perform all needed animations in this block.
 */
- (void)keyboardWillShowAnimated:(NSNotification *)keyboardNotification;
- (void)keyboardWillHideAnimated:(NSNotification *)keyboardNotification;

@end
