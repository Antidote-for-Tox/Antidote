//
//  AudioCallViewController.m
//  Antidote
//
//  Created by Chuong Vu on 8/17/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "AudioCallViewController.h"
#import "Masonry.h"
#import "ExpandedControlsView.h"

static const CGFloat kIndent = 50.0;

@interface AudioCallViewController () <CallControlsViewDelegate>

@property (strong, nonatomic) ExpandedControlsView *expandedControlsView;

@end

@implementation AudioCallViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createExpandedCallControlsView];

    [self installConstraints];
}

- (void)createExpandedCallControlsView
{
    self.expandedControlsView = [ExpandedControlsView new];
    self.expandedControlsView.delegate = self;
    self.expandedControlsView.micSelected = self.micSelected;
    self.expandedControlsView.speakerSelected = self.speakerSelected;

    [self.view addSubview:self.expandedControlsView];
}

- (void)installConstraints
{
    [super installConstraints];

    [self.expandedControlsView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topViewContainer.bottom).with.offset(kIndent);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

#pragma mark - Public

- (void)setMicSelected:(BOOL)micSelected
{
    [super setMicSelected:micSelected];

    self.expandedControlsView.micSelected = micSelected;
}

- (void)setSpeakerSelected:(BOOL)speakerSelected
{
    [super setSpeakerSelected:speakerSelected];

    self.expandedControlsView.speakerSelected = speakerSelected;
}

- (void)setVideoButtonSelected:(BOOL)videoButtonSelected
{
    [super setVideoButtonSelected:videoButtonSelected];

    self.expandedControlsView.videoButtonSelected = videoButtonSelected;
}

- (void)setResumeButtonHidden:(BOOL)resumeButtonHidden
{
    [super setResumeButtonHidden:resumeButtonHidden];

    if (self.expandedControlsView.resumeButtonHidden == resumeButtonHidden) {
        return;
    }

    self.expandedControlsView.resumeButtonHidden = resumeButtonHidden;
    self.expandedControlsView.hidden = ! resumeButtonHidden;
}

- (void)friendPausedCall:(BOOL)paused
{
    [super friendPausedCall:paused];

    [self.expandedControlsView mainControlsHide:paused];
}

#pragma mark - CallControlsViewDelegate

- (void)callControlsMicButtonPressed:(ExpandedControlsView *)callsControlView
{
    [self.delegate activeCallMicButtonPressed:self];
}

- (void)callControlsSpeakerButtonPressed:(ExpandedControlsView *)callsControlView
{
    [self.delegate activeCallSpeakerButtonPressed:self];
}

- (void)callControlsResumeButtonPressed:(ExpandedControlsView *)callsControlView
{
    [self.delegate activeCallResumeButtonPressed:self];
}

- (void)callControlsVideoButtonPressed:(ExpandedControlsView *)callsControlView
{
    [self.delegate activeCallVideoButtonPressed:self];
}

- (void)callControlsEndCallButtonPressed:(ExpandedControlsView *)callsControlView
{
    [self.delegate activeCallDeclineButtonPressed:self];
}

@end
