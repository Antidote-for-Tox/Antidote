//
//  ActiveCallViewController.h
//  Antidote
//
//  Created by Chuong Vu on 7/2/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AbstractCallViewController.h"

@class ActiveCallViewController;
/**
 * This controller is used during an active call.
 */
@protocol ActiveCallViewControllerDelegate <NSObject>

- (void)activeCallDeclineButtonPressed:(ActiveCallViewController *)controller;
- (void)activeCallMicButtonPressed:(ActiveCallViewController *)controller;
- (void)activeCallSpeakerButtonPressed:(ActiveCallViewController *)controller;
- (void)activeCallDeclineIncomingCallButtonPressed:(ActiveCallViewController *)controller;
- (void)activeCallAnswerIncomingCallButtonPressed:(ActiveCallViewController *)controller;
- (void)activeCallPausedCallSelectedAtIndex:(NSUInteger)index controller:(ActiveCallViewController *)controller;

@end

@interface ActiveCallViewController : AbstractCallViewController

/**
 * Delegate for call touches.
 */
@property (weak, nonatomic) id<ActiveCallViewControllerDelegate> delegate;

/**
 * The duration of the call.
 */
@property (nonatomic, assign) NSTimeInterval callDuration;

/**
 * Set the microphone to be selected or not selected
 */
@property (assign, nonatomic) BOOL micSelected;

/**
 * Set the speaker to be selected or not selected
 */
@property (assign, nonatomic) BOOL speakerSelected;

/**
 * Set to YES to show an incoming call
 */
@property (assign, nonatomic) BOOL showIncomingCallView;

/**
 * Set the name of the other caller who is calling
 */
@property (strong, nonatomic) NSString *incomingCallCallerName;
@end
