//
//  AbstractCallViewController.h
//  Antidote
//
//  Created by Chuong Vu on 7/2/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OCTSubmanagerCalls;
@class OCTChat;
@class OCTCall;

@interface AbstractCallViewController : UIViewController

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * Create an instance of the CallViewController.
 * @param chat Appropriate chat for the call.
 * @param manager The call maanger for the application.
 */
- (instancetype)initWithCall:(OCTCall *)call submanagerCalls:(OCTSubmanagerCalls *)manager;

/**
 * The call associated with this view controller.
 */
@property (strong, nonatomic, readonly) OCTCall *call;

/**
 * The call manager responsible for call handling.
 */
@property (weak, nonatomic) OCTSubmanagerCalls *manager;

@property (strong, nonatomic, readonly) UILabel *nameLabel;

/**
 * This is called whenever the call is updated.
 * Override this to include any other updates as needed.
 */
- (void)didUpdateCall NS_REQUIRES_SUPER;

/**
 * Install constraints for subviews.
 * Override this to include any other constraints in your subclass.
 */
- (void)installConstraints NS_REQUIRES_SUPER;

@end
