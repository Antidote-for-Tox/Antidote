//
//  VideoCallViewController.m
//  Antidote
//
//  Created by Chuong Vu on 8/17/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "VideoCallViewController.h"
#import "Masonry.h"
#import "VideoAndPreviewView.h"
#import "CompactControlsView.h"

static const CGFloat kCompactLandScapeXIndent = 100.0;
static const CGFloat kCompactControlsHeight = 60.0;

@interface VideoCallViewController () <VideoAndPreviewViewDelegate,
                                       CallControlsViewDelegate>

@property (strong, nonatomic) VideoAndPreviewView *videoContainerView;
@property (strong, nonatomic) CompactControlsView *compactControlsView;

@end

@implementation VideoCallViewController

#pragma mark - View setup
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createVideoContainerView];
    [self createCompactCallControlsView];

    [self installConstraints];
}

- (void)createVideoContainerView
{
    self.videoContainerView = [VideoAndPreviewView new];
    self.videoContainerView.delegate = self;

    [self.view insertSubview:self.videoContainerView belowSubview:self.topViewContainer];
}

- (void)createCompactCallControlsView
{
    self.compactControlsView = [CompactControlsView new];
    self.compactControlsView.delegate = self;
    self.compactControlsView.videoButtonSelected = self.videoButtonSelected;
    self.compactControlsView.micSelected = self.micSelected;
    self.compactControlsView.speakerSelected = self.speakerSelected;

    [self.view addSubview:self.compactControlsView];
}


- (void)installConstraints
{
    [super installConstraints];

    [self.videoContainerView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.compactControlsView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(kCompactControlsHeight);
    }];

    [self updateUIForInterfaceOrientation:self.interfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateUIForInterfaceOrientation:toInterfaceOrientation];

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)updateUIForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    const BOOL isPortrait = UIInterfaceOrientationIsPortrait(interfaceOrientation);

    const CGFloat compactControlsXIndents = isPortrait ? 0.0 : kCompactLandScapeXIndent;

    [self.compactControlsView updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(compactControlsXIndents);
        make.right.equalTo(self.view).with.offset(-compactControlsXIndents);
    }];

}

#pragma mark - Public

- (BOOL)videoViewIsShown
{
    return (self.videoContainerView.videoView != nil);
}

- (void)provideVideoView:(UIView *)view
{
    self.videoContainerView.videoView = view;
}

- (void)providePreviewLayer:(CALayer *)layer
{
    [self.videoContainerView providePreviewLayer:layer];
}

- (void)setMicSelected:(BOOL)micSelected
{
    [super setMicSelected:micSelected];

    self.compactControlsView.micSelected = micSelected;
}

- (void)setSpeakerSelected:(BOOL)speakerSelected
{
    [super setSpeakerSelected:speakerSelected];

    self.compactControlsView.speakerSelected = speakerSelected;
}

- (void)setVideoButtonSelected:(BOOL)videoButtonSelected
{
    [super setVideoButtonSelected:videoButtonSelected];

    self.compactControlsView.videoButtonSelected = videoButtonSelected;
}

- (void)setResumeButtonHidden:(BOOL)resumeButtonHidden
{
    [super setResumeButtonHidden:resumeButtonHidden];

    if (self.compactControlsView.resumeButtonHidden == resumeButtonHidden) {
        return;
    }

    self.compactControlsView.resumeButtonHidden = resumeButtonHidden;
}


#pragma mark - VideoAndPreviewViewDelegate

- (void)videoAndPreviewViewTapped:(VideoAndPreviewView *)videoView
{
    BOOL hidden = (self.topViewContainer.alpha == 1.0);

    CGFloat newAlpha = (self.topViewContainer.alpha == 0.0) ? 1.0 : 0.0;

    if (newAlpha == 1.0) {
        self.topViewContainer.hidden = NO;
        self.compactControlsView.hidden = NO;
    }

    [UIView animateWithDuration:1.0
                     animations:^{
        self.topViewContainer.alpha = newAlpha;
        self.compactControlsView.alpha = newAlpha;
    } completion:^(BOOL finished) {
        self.topViewContainer.hidden = hidden;
        self.compactControlsView.hidden = hidden;
    }];
}

#pragma mark - CallControlsViewDelegate

- (void)callControlsMicButtonPressed:(CompactControlsView *)callsControlView
{
    [self.delegate activeCallMicButtonPressed:self];
}

- (void)callControlsSpeakerButtonPressed:(CompactControlsView *)callsControlView
{
    [self.delegate activeCallSpeakerButtonPressed:self];
}

- (void)callControlsResumeButtonPressed:(CompactControlsView *)callsControlView
{
    [self.delegate activeCallResumeButtonPressed:self];
}

- (void)callControlsVideoButtonPressed:(CompactControlsView *)callsControlView
{
    [self.delegate activeCallVideoButtonPressed:self];
}

- (void)callControlsEndCallButtonPressed:(CompactControlsView *)callsControlView
{
    [self.delegate activeCallDeclineButtonPressed:self];
}


@end
