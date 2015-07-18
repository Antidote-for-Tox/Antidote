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
- (void)activeCallPauseButtonPressed:(ActiveCallViewController *)controller;

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
 * Set the pause buton to be selected or not selected.
 */
@property (assign, nonatomic) BOOL pauseSelected;

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

@end
