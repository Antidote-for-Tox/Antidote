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
#import "CompactControlsView.h"
#import "AvatarsManager.h"

static const CGFloat kIndent = 50.0;
static const CGFloat kCompactControlsHeight = 80.0;
static const CGFloat kAvatarPadding = 5.0;

@interface AudioCallViewController () <CallControlsViewDelegate>

@property (strong, nonatomic) ExpandedControlsView *expandedControlsView;
@property (strong, nonatomic) CompactControlsView *compactedControlsView;
@property (strong, nonatomic) UIImageView *landscapeAvatar;

@end

@implementation AudioCallViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createExpandedCallControlsView];
    [self createCompactedCallControlsView];

    [self installConstraints];

    [self showControlsForOrientation:self.interfaceOrientation];
}

- (void)createExpandedCallControlsView
{
    self.expandedControlsView = [ExpandedControlsView new];
    self.expandedControlsView.delegate = self;
    self.expandedControlsView.micSelected = self.micSelected;
    self.expandedControlsView.speakerSelected = self.speakerSelected;

    [self.view addSubview:self.expandedControlsView];
}

- (void)createCompactedCallControlsView
{
    self.compactedControlsView = [CompactControlsView new];
    self.compactedControlsView.delegate = self;
    self.compactedControlsView.micSelected = self.micSelected;
    self.compactedControlsView.speakerSelected = self.speakerSelected;

    [self.view addSubview:self.compactedControlsView];
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

    [self.compactedControlsView makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(kCompactControlsHeight);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    [self showControlsForOrientation:toInterfaceOrientation];

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self showAvatarIfNeeded];
}

- (void)showControlsForOrientation:(UIInterfaceOrientation)orientation
{
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);

    self.expandedControlsView.hidden = ! isPortrait;
    self.compactedControlsView.hidden = isPortrait;
}


#pragma mark - Public

- (void)setMicSelected:(BOOL)micSelected
{
    [super setMicSelected:micSelected];

    self.expandedControlsView.micSelected = micSelected;
    self.compactedControlsView.micSelected = micSelected;
}

- (void)setSpeakerSelected:(BOOL)speakerSelected
{
    [super setSpeakerSelected:speakerSelected];

    self.expandedControlsView.speakerSelected = speakerSelected;
    self.compactedControlsView.speakerSelected = speakerSelected;
}

- (void)setVideoButtonSelected:(BOOL)videoButtonSelected
{
    [super setVideoButtonSelected:videoButtonSelected];

    self.expandedControlsView.videoButtonSelected = videoButtonSelected;
    self.compactedControlsView.videoButtonSelected = videoButtonSelected;
}

- (void)setResumeButtonHidden:(BOOL)resumeButtonHidden
{
    [super setResumeButtonHidden:resumeButtonHidden];

    if (self.expandedControlsView.resumeButtonHidden == resumeButtonHidden) {
        return;
    }

    self.expandedControlsView.resumeButtonHidden = resumeButtonHidden;
    self.compactedControlsView.resumeButtonHidden = resumeButtonHidden;
}

- (void)friendPausedCall:(BOOL)paused
{
    [super friendPausedCall:paused];

    [self.expandedControlsView mainControlsHide:paused];
}

#pragma mark - Private

- (void)showAvatarIfNeeded
{
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);

    if (! isLandscape) {
        [self.landscapeAvatar removeFromSuperview];
        self.landscapeAvatar = nil;
        return;
    }

    CGFloat bottomOfTopContainer = CGRectGetMaxY(self.topViewContainer.frame);
    CGFloat topOfCompactControls = CGRectGetMinY(self.compactedControlsView.frame);

    CGFloat avatarDiameter = topOfCompactControls - bottomOfTopContainer - kAvatarPadding;

    AvatarsManager *avatars = [AppContext sharedContext].avatars;

    UIImage *image = [avatars avatarFromString:self.nickname
                                      diameter:avatarDiameter
                                     textColor:[UIColor whiteColor]
                               backgroundColor:[UIColor clearColor]];

    self.landscapeAvatar = [[UIImageView alloc] initWithImage:image];

    [self.view addSubview:self.landscapeAvatar];

    [self.landscapeAvatar makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(self.landscapeAvatar.height);
    }];
}

#pragma mark - CallControlsViewDelegate

- (void)callControlsMicButtonPressed:(id <CallControlsViewProtocol>)callsControlView
{
    [self.delegate activeCallMicButtonPressed:self];
}

- (void)callControlsSpeakerButtonPressed:(id <CallControlsViewProtocol>)callsControlView
{
    [self.delegate activeCallSpeakerButtonPressed:self];
}

- (void)callControlsResumeButtonPressed:(id <CallControlsViewProtocol>)callsControlView
{
    [self.delegate activeCallResumeButtonPressed:self];
}

- (void)callControlsVideoButtonPressed:(id <CallControlsViewProtocol>)callsControlView
{
    [self.delegate activeCallVideoButtonPressed:self];
}

- (void)callControlsEndCallButtonPressed:(id <CallControlsViewProtocol>)callsControlView
{
    [self.delegate activeCallDeclineButtonPressed:self];
}

@end
