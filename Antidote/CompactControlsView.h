//
//  CompactControlsView.h
//  Antidote
//
//  Created by Chuong Vu on 8/10/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CompactControlsView;

@protocol CompactControlsViewDelegate <NSObject>

- (void)compactControlsMicButtonPressed:(CompactControlsView *)compactControlsView;
- (void)compactControlsSpeakerButtonPressed:(CompactControlsView *)compactControlsView;
- (void)compactControlsResumeButtonPressed:(CompactControlsView *)compactControlsView;
- (void)compactControlsVideoButtonPressed:(CompactControlsView *)compactControlsView;
- (void)compactControlsEndCallButtonPressed:(CompactControlsView *)compactControlsView;

@end

@interface CompactControlsView : UIView

@property (nonatomic, weak) id<CompactControlsViewDelegate> delegate;

/**
 * Set the video button to be selected or not selected
 */
@property (assign, nonatomic) BOOL videoButtonSelected;

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

@end
