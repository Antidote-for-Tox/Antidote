//
//  CallControlsView.m
//  Antidote
//
//  Created by Chuong Vu on 7/27/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "CallControlsView.h"
#import "AppearanceManager.h"
#import "CompactControlsView.h"
#import "Masonry.h"

static const CGFloat kButtonBorderWidth = 1.5f;
static const CGFloat k3ButtonGap = 30.0;

@interface CallControlsView () <CompactControlsViewDelegate>

@property (strong, nonatomic) UIButton *videoButton;
@property (strong, nonatomic) UIButton *microphoneButton;
@property (strong, nonatomic) UIButton *speakerButton;
@property (strong, nonatomic) UIButton *resumeButton;
@property (strong, nonatomic) UIView *expandedView;

@property (strong, nonatomic) CompactControlsView *compactView;

@property (strong, nonatomic) MASConstraint *videoHorizontalConstraint;

@end

@implementation CallControlsView

- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    self.backgroundColor = [UIColor clearColor];

    [self createExpandedView];
    [self createCompactView];

    [self createVideoButton];
    [self createMicrophoneButton];
    [self createSpeakerButton];
    [self createResumeButton];

    [self installConstraints];

    return self;
}

- (void)createExpandedView
{
    self.expandedView = [UIView new];
    [self addSubview:self.expandedView];
}

- (void)createCompactView
{
    self.compactView = [CompactControlsView new];
    self.compactView.delegate = self;

    self.compactView.hidden = YES;
}
- (void)createVideoButton
{
    self.videoButton = [self createCircularButtonWithImageName:@"call-video" action:@selector(videoButtonPressed)];

    [self.expandedView addSubview:self.videoButton];
}

- (void)createMicrophoneButton
{
    self.microphoneButton = [self createCircularButtonWithImageName:@"call-microphone-disable" action:@selector(micButtonPressed)];

    [self.expandedView addSubview:self.microphoneButton];
}

- (void)createSpeakerButton
{
    self.speakerButton = [self createCircularButtonWithImageName:@"call-audio-enable" action:@selector(speakerButtonPressed)];

    [self.expandedView addSubview:self.speakerButton];
}

- (void)createResumeButton
{
    self.resumeButton = [self createCircularButtonWithImageName:@"call-pause" action:@selector(resumeButtonPressed)];
    self.resumeButton.tintColor = [[AppContext sharedContext].appearance callRedColor];
    self.resumeButton.layer.borderColor = [[AppContext sharedContext].appearance callRedColor].CGColor;
    self.resumeButton.hidden = YES;

    [self.expandedView addSubview:self.resumeButton];
}

- (void)installConstraints
{
    [self.videoButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.height.equalTo(self.videoButton.width);
        make.bottom.equalTo(self.microphoneButton.top).with.offset(-k3ButtonGap);

        self.videoHorizontalConstraint = make.centerX.equalTo(self);
    }];

    [self.resumeButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.videoButton.left).with.offset(-k3ButtonGap);
        make.centerY.equalTo(self.videoButton);
        make.size.equalTo(self.videoButton);
    }];

    [self.microphoneButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.expandedView);
        make.right.equalTo(self.speakerButton.left).with.offset(-k3ButtonGap);
        make.size.equalTo(self.videoButton);
        make.top.equalTo(self.videoButton.bottom).with.offset(k3ButtonGap);
    }];

    [self.speakerButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.expandedView);
        make.size.equalTo(self.videoButton);
        make.centerY.equalTo(self.microphoneButton);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutIfNeeded];
    [self updateCornerRadius];
}

#pragma mark - Touch actions

- (void)micButtonPressed
{
    [self.delegate callControlsMicButtonPressed:self];
}

- (void)speakerButtonPressed
{
    [self.delegate callControlsSpeakerButtonPressed:self];
}

- (void)resumeButtonPressed
{
    [self.delegate callControlsResumeButtonPressed:self];
}

- (void)videoButtonPressed
{
    [self.delegate callControlsVideoButtonPressed:self];
}

- (void)endCallButtonPressed
{
    [self.delegate callControlsEndCallButtonPressed:self];
}

#pragma mark - CompactControlsViewDelegate

- (void)compactControlsVideoButtonPressed:(CompactControlsView *)compactControlsView
{
    [self.delegate callControlsVideoButtonPressed:self];
}

- (void)compactControlsMicButtonPressed:(CompactControlsView *)compactControlsView
{
    [self.delegate callControlsMicButtonPressed:self];
}

- (void)compactControlsSpeakerButtonPressed:(CompactControlsView *)compactControlsView
{
    [self.delegate callControlsSpeakerButtonPressed:self];
}

- (void)compactControlsEndCallButtonPressed:(CompactControlsView *)compactControlsView
{
    [self.delegate callControlsEndCallButtonPressed:self];
}

- (void)compactControlsResumeButtonPressed:(CompactControlsView *)compactControlsView
{
    [self.delegate callControlsResumeButtonPressed:self];
}

#pragma mark - Public

- (void)setType:(CallsControlsViewType)type
{
    _type = type;

    self.compactView.hidden = (type == CallsControlsViewTypeExpand);
    self.expandedView.hidden = (type == CallsControlsViewTypeCompact);

    if (type == CallsControlsViewTypeCompact) {
        [self.expandedView removeFromSuperview];
        [self addSubview:self.compactView];
        [self.compactView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    else {
        [self.compactView removeFromSuperview];
        [self addSubview:self.expandedView];
        [self.expandedView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
}

- (void)setMicSelected:(BOOL)micSelected
{
    self.microphoneButton.selected = micSelected;
    self.compactView.micSelected = micSelected;

    [self setButton:self.microphoneButton selected:micSelected];
}

- (BOOL)micSelected
{
    return self.microphoneButton.selected;
}

- (void)setSpeakerSelected:(BOOL)speakerSelected
{
    self.speakerButton.selected = speakerSelected;
    self.compactView.speakerSelected = speakerSelected;

    [self setButton:self.speakerButton selected:speakerSelected];
}

- (BOOL)speakerSelected
{
    return self.speakerButton.selected;
}

- (void)setResumeButtonHidden:(BOOL)resumeButtonHidden
{
    self.resumeButton.hidden = resumeButtonHidden;

    [self.videoHorizontalConstraint uninstall];

    if (resumeButtonHidden) {

        [self.videoButton updateConstraints:^(MASConstraintMaker *make) {
            self.videoHorizontalConstraint = make.centerX.equalTo(self);
        }];
    }
    else {

        [self.videoButton updateConstraints:^(MASConstraintMaker *make) {
            self.videoHorizontalConstraint = make.right.equalTo(self);
        }];
    }
}

- (BOOL)resumeButtonHidden
{
    return self.resumeButton.hidden;
}

- (void)setVideoButtonSelected:(BOOL)selected
{
    self.compactView.videoButtonSelected = selected;
}

#pragma mark - Private

- (UIButton *)createCircularButtonWithImageName:(NSString *)imageName action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:imageName];
    [button setImage:image forState:UIControlStateNormal];

    button.tintColor = [UIColor whiteColor];

    button.contentMode = UIViewContentModeScaleAspectFill;
    button.layer.masksToBounds = YES;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = kButtonBorderWidth;

    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (void)setButton:(UIButton *)button selected:(BOOL)selected
{
    if (selected) {
        button.backgroundColor = [UIColor whiteColor];
        button.tintColor = [UIColor grayColor];
    }
    else {
        button.backgroundColor = [UIColor clearColor];
        button.tintColor = [UIColor whiteColor];
    }
}

- (void)updateCornerRadius
{
    CGFloat newCornerRadius = self.videoButton.frame.size.height / 2.0;
    self.videoButton.layer.cornerRadius = newCornerRadius;
    self.microphoneButton.layer.cornerRadius = newCornerRadius;
    self.speakerButton.layer.cornerRadius = newCornerRadius;
    self.resumeButton.layer.cornerRadius = newCornerRadius;
}

@end
