//
//  CallControlsView.h
//  Antidote
//
//  Created by Chuong Vu on 7/27/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CallControlsView;

@protocol CallControlsViewDelegate <NSObject>

- (void)callControlsMicButtonPressed:(CallControlsView *)callsControlView;
- (void)callControlsSpeakerButtonPressed:(CallControlsView *)callsControlView;
- (void)callControlsResumeButtonPressed:(CallControlsView *)callsControlView;
- (void)callControlsVideoButtonPressed:(CallControlsView *)callsControlView;
- (void)callControlsEndCallButtonPressed:(CallControlsView *)callsControlView;

@end

typedef NS_ENUM(NSUInteger, CallsControlsViewType) {
    /**
     * Use this view for audio controls.
     */
    CallsControlsViewTypeExpand,

    /**
     * Use this view when showing video.
     * Controls are set up horizontally |-video-mic-speaker-endCall-|
     */
    CallsControlsViewTypeCompact,
};

@interface CallControlsView : UIView

/**
 * The current view type.
 */
@property (nonatomic, assign) CallsControlsViewType type;

@property (weak, nonatomic) id<CallControlsViewDelegate> delegate;

/**
 * Set the microphone to be selected or not selected
 */
@property (assign, nonatomic) BOOL micSelected;

/**
 * Set the speaker to be selected or not selected
 */
@property (assign, nonatomic) BOOL speakerSelected;

/**
 * Set the resume button to be hidden or not.
 */
@property (assign, nonatomic) BOOL resumeButtonHidden;

/**
 * Set wehther or not the video button is selected.
 */
- (void)setVideoButtonSelected:(BOOL)selected;

@end
