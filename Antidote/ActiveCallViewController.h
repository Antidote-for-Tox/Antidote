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
- (void)activeCallResumeButtonPressed:(ActiveCallViewController *)controller;
- (void)activeCallVideoButtonPressed:(ActiveCallViewController *)controller;

- (void)activeCallDeclineIncomingCallButtonPressed:(ActiveCallViewController *)controller;
- (void)activeCallAnswerIncomingCallButtonPressed:(ActiveCallViewController *)controller;

@end

@protocol ActiveCallViewControllerDataSource <NSObject>

- (NSInteger)activeCallControllerNumberOfPausedCalls:(ActiveCallViewController *)controller;
- (NSString *)activeCallController:(ActiveCallViewController *)controller pausedCallerNicknameForCallAtIndex:(NSIndexPath *)indexPath;
- (NSDate *)activeCallController:(ActiveCallViewController *)controller pauseDateForCallAtIndex:(NSIndexPath *)indexPath;
- (void)activeCallController:(ActiveCallViewController *)controller resumePausedCallSelectedAtIndex:(NSIndexPath *)indexPath;
- (void)activeCallController:(ActiveCallViewController *)controller endPausedCallSelectedAtIndex:(NSIndexPath *)indexPath;

@end

@interface ActiveCallViewController : AbstractCallViewController

/**
 * Delegate for call touches.
 */
@property (weak, nonatomic) id<ActiveCallViewControllerDelegate> delegate;

/**
 * Datasource for paused calls
 */
@property (weak, nonatomic) id<ActiveCallViewControllerDataSource> dataSource;

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
 * Set video button selected.
 */
@property (assign, nonatomic) BOOL videoButtonSelected;

/**
 * Set whether or not the resume button is hidden.
 */
@property (assign, nonatomic) BOOL resumeButtonHidden;

/**
 * YES if the video view is being shown, otherwise NO.
 */
@property (nonatomic, assign, readonly) BOOL videoViewIsShown;

/**
 * Since it takes a while for the preview layer to be loaded,
 * it is best to set this to YES to indicate that one is loaded and in progress
 * or that it is already present.
 * Set to YES if the preview view is being shown, otherwise NO.
 */
@property (nonatomic, assign) BOOL previewViewIsShown;

/**
 * Create an incoming call view for friend
 * @param nickname Nickname of friend
 */
- (void)createIncomingCallViewForFriend:(NSString *)nickname;

/**
 * Hide incoming call view
 */
- (void)hideIncomingCallView;

/**
 * Reload the table of paused calls.
 * Use this when there is a new change.
 */
- (void)reloadPausedCalls;

/**
 * Use this when the friend has paused the call.
 */
- (void)showCallPausedByFriend;

/**
 * Provide video view to view controller
 * @param view Video view to provide.
 */
- (void)provideVideoView:(UIView *)view;

/**
 * Provide preview view layer to view controller.
 * @param layer Layer of the preview video.
 */
- (void)providePreviewLayer:(CALayer *)layer;

@end
