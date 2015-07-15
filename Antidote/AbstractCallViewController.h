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
 * Abstract delegate
 */
@property (weak, nonatomic) id delegate;

/**
 * Name of the caller
 */
@property (strong, nonatomic) NSString *nickname;

/**
 * Label of the caller.
 */
@property (strong, nonatomic, readonly) UILabel *nameLabel;

/**
 * Install constraints for subviews.
 * Override this to include any other constraints in your subclass.
 */
- (void)installConstraints NS_REQUIRES_SUPER;

@end
