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

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * Create an instance of the AbstractCallViewController.
 * @param nickname The nickname associated with the caller.
 */
- (instancetype)initWithCallerNickname:(NSString *)nickname;

/**
 * Abstract delegate
 */
@property (weak, nonatomic) id delegate;

/**
 * Name of the caller
 */
@property (strong, nonatomic, readonly) NSString *nickname;

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
