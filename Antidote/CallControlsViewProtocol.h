//
//  CallControlsViewProtocol.h
//  Antidote
//
//  Created by Chuong Vu on 8/11/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

@protocol CallControlsViewProtocol <NSObject>

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
 * Set the video button to be selected or not selected
 */
@property (assign, nonatomic) BOOL videoButtonSelected;

@end

@protocol CallControlsViewDelegate <NSObject>

- (void)callControlsMicButtonPressed:(id<CallControlsViewProtocol>)callControlsView;
- (void)callControlsSpeakerButtonPressed:(id<CallControlsViewProtocol>)callControlsView;
- (void)callControlsResumeButtonPressed:(id<CallControlsViewProtocol>)callControlsView;
- (void)callControlsVideoButtonPressed:(id<CallControlsViewProtocol>)callControlsView;
- (void)callControlsEndCallButtonPressed:(id<CallControlsViewProtocol>)callControlsView;

@end
