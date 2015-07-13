//
//  AbstractCallViewController.h
//  Antidote
//
//  Created by Chuong Vu on 7/2/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OCTToxAVConstants.h"

@class OCTSubmanagerCalls;
@class OCTChat;
@class OCTCall;

@protocol AbstractCallViewControllerDelegate <NSObject>

@required
- (void)dismissCurrentCall;
- (void)callAccept;
- (BOOL)sendCallControl:(OCTToxAVCallControl)control error:(NSError **)error;

- (void)otherCallAccept:(BOOL)accept;

@property (nonatomic, assign) BOOL enableMicrophone;

@end

@interface AbstractCallViewController : UIViewController

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * Create an instance of the AbstractCallViewController.
 * @param nickname The nickname associated with the caller.
 */
- (instancetype)initWithCallerNickname:(NSString *)nickname;

/**
 * Name of the caller
 */
@property (strong, nonatomic, readonly) NSString *nickname;

/**
 * The AbstractCallViewControllerDelegate.
 */
@property (weak, nonatomic) id <AbstractCallViewControllerDelegate> delegate;

/**
 * Label of the caller.
 */
@property (strong, nonatomic, readonly) UILabel *nameLabel;

/**
 * The duration of the call.
 */
@property (nonatomic, assign) NSTimeInterval callDuration;

/**
 * Install constraints for subviews.
 * Override this to include any other constraints in your subclass.
 */
- (void)installConstraints NS_REQUIRES_SUPER;

/**
 * Use this to notify of an incoming call.
 * @param call The call that is incoming
 */
- (void)incomingCallFromFriend:(NSString *)nickname;

/**
 * Ends the current call.
 */
- (void)endCurrentCall;

@end
