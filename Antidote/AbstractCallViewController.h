//
//  AbstractCallViewController.h
//  Antidote
//
//  Created by Chuong Vu on 7/2/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OCTToxAVConstants.h"

@interface AbstractCallViewController : UIViewController

/**
 * Name of the caller
 */
@property (strong, nonatomic) NSString *nickname;

/**
 * This view container holds onto both the nameLabel and subLabel
 */
@property (strong, nonatomic, readonly) UIView *topViewContainer;

/**
 * Label of the caller.
 */
@property (strong, nonatomic, readonly) UILabel *nameLabel;

/**
 * This label sits below the name label. Change the text
 * to display any additional status.
 */
@property (strong, nonatomic, readonly) UILabel *subLabel;

/**
 * Install constraints for subviews.
 * Override this to include any other constraints in your subclass.
 */
- (void)installConstraints NS_REQUIRES_SUPER;

@end
