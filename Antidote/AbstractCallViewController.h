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

/**
 * Label of the caller.
 */
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

/**
 * End the call.
 * This can be used to cancel a call, end an active one or reject a call.
 * Note, ending the call will dismiss the view controller itself.
 */
- (void)endCall;

/**
 * Switch to a different call
 * Will switch to the appropriate view controller based
 * on call status.
 * Calling this will dismiss the current view controller.
 * @param call Call to switch to
 */
- (void)switchToCall:(OCTCall *)call;

/**
 * Use this to notify of a new incoming call.
 * @param call The call that is incoming
 */
- (void)displayNotificationOfNewCall:(OCTCall *)call;

@end
