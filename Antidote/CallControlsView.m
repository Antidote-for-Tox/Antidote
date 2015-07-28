//
//  CallControlsView.m
//  Antidote
//
//  Created by Chuong Vu on 7/27/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "CallControlsView.h"
#import "AppearanceManager.h"
#import "Masonry.h"

static const CGFloat kButtonBorderWidth = 1.5f;
static const CGFloat kButtonSide = 75.0;
static const CGFloat k3ButtonGap = 15.0;

@interface CallControlsView ()

@property (strong, nonatomic) UIButton *videoButton;
@property (strong, nonatomic) UIButton *microphoneButton;
@property (strong, nonatomic) UIButton *speakerButton;
@property (strong, nonatomic) UIButton *resumeButton;

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

    [self createVideoButton];
    [self createMicrophoneButton];
    [self createSpeakerButton];
    [self createResumeButton];

    [self installConstraints];

    [self hideResumeButton];

    return self;
}

- (void)createVideoButton
{
    self.videoButton = [self createButtonWithImageName:@"call-video" action:nil];

    [self addSubview:self.videoButton];
}

- (void)createMicrophoneButton
{
    self.microphoneButton = [self createButtonWithImageName:@"call-microphone-disable" action:@selector(micButtonPressed)];

    [self addSubview:self.microphoneButton];
}

- (void)createSpeakerButton
{
    self.speakerButton = [self createButtonWithImageName:@"call-audio-enable" action:@selector(speakerButtonPressed)];

    [self addSubview:self.speakerButton];
}

- (void)createResumeButton
{
    self.resumeButton = [self createButtonWithImageName:@"call-pause" action:@selector(resumeButtonPressed)];
    self.resumeButton.tintColor = [[AppContext sharedContext].appearance callRedColor];
    self.resumeButton.layer.borderColor = [[AppContext sharedContext].appearance callRedColor].CGColor;

    [self addSubview:self.resumeButton];
}

- (void)installConstraints
{
    [self.videoButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.size.equalTo(kButtonSide);
        make.bottom.equalTo(self.microphoneButton.top).with.offset(-k3ButtonGap);

        self.videoHorizontalConstraint = make.centerX.equalTo(self);
    }];

    [self.resumeButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.videoButton.left).with.offset(-k3ButtonGap);
        make.centerY.equalTo(self.videoButton);
        make.size.equalTo(kButtonSide);
    }];

    [self.microphoneButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self.speakerButton.left).with.offset(-k3ButtonGap);
        make.size.equalTo(kButtonSide);
        make.top.equalTo(self.videoButton.bottom).with.offset(k3ButtonGap);
    }];

    [self.speakerButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.size.equalTo(kButtonSide);
        make.centerY.equalTo(self.microphoneButton);
    }];

    [self makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoButton);
        make.bottom.equalTo(self.microphoneButton);
    }];
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

#pragma makr - Public

- (void)setMicSelected:(BOOL)micSelected
{
    self.microphoneButton.selected = micSelected;

    if (micSelected) {
        self.microphoneButton.backgroundColor = [UIColor whiteColor];
        self.microphoneButton.tintColor = [UIColor grayColor];
    }
    else {
        self.microphoneButton.backgroundColor = [UIColor clearColor];
        self.microphoneButton.tintColor = [UIColor whiteColor];
    }
}

- (BOOL)micSelected
{
    return self.microphoneButton.selected;
}

- (void)setSpeakerSelected:(BOOL)speakerSelected
{
    self.speakerButton.selected = speakerSelected;

    if (speakerSelected) {
        self.speakerButton.backgroundColor = [UIColor whiteColor];
        self.speakerButton.tintColor = [UIColor grayColor];
    }
    else {
        self.speakerButton.backgroundColor = [UIColor clearColor];
        self.speakerButton.tintColor = [UIColor whiteColor];
    }
}

- (BOOL)speakerSelected
{
    return self.speakerButton.selected;
}

- (void)showResumeButton
{
    self.resumeButton.hidden = NO;

    [self.videoHorizontalConstraint uninstall];

    [self.videoButton updateConstraints:^(MASConstraintMaker *make) {
        self.videoHorizontalConstraint = make.right.equalTo(self);
    }];
}

- (void)hideResumeButton
{
    self.resumeButton.hidden = YES;

    [self.videoHorizontalConstraint uninstall];

    [self.videoButton updateConstraints:^(MASConstraintMaker *make) {
        self.videoHorizontalConstraint = make.centerX.equalTo(self);
    }];
}

#pragma mark - Private

- (UIButton *)createButtonWithImageName:(NSString *)imageName action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:imageName];
    [button setImage:image forState:UIControlStateNormal];

    button.tintColor = [UIColor whiteColor];

    button.contentMode = UIViewContentModeScaleAspectFill;
    button.layer.cornerRadius = kButtonSide / 2.0f;
    button.layer.masksToBounds = YES;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = kButtonBorderWidth;

    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];

    return button;
}

@end
