//
//  CallControlsView.m
//  Antidote
//
//  Created by Chuong Vu on 7/27/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ExpandedControlsView.h"
#import "AppearanceManager.h"
#import "Masonry.h"

static const CGFloat kButtonBorderWidth = 1.5f;
static const CGFloat k3ButtonGap = 30.0;
static const CGFloat kEndCallButtonHeight = 45.0;
static const CGFloat kIndent = 50.0;
static const CGFloat kControlsContainerSpaceFromEndCall = 100.0;

@interface ExpandedControlsView ()

@property (strong, nonatomic) UIButton *videoButton;
@property (strong, nonatomic) UIButton *microphoneButton;
@property (strong, nonatomic) UIButton *speakerButton;
@property (strong, nonatomic) UIButton *resumeButton;
@property (strong, nonatomic) UIButton *endCallButton;

@property (strong, nonatomic) UIView *callControlsContainer;

@property (strong, nonatomic) MASConstraint *videoHorizontalConstraint;

@end

@implementation ExpandedControlsView

- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    [self createCallControlsContainer];
    [self createVideoButton];
    [self createMicrophoneButton];
    [self createSpeakerButton];
    [self createResumeButton];
    [self createEndCallButton];

    [self installConstraints];

    return self;
}

- (void)createCallControlsContainer
{
    self.callControlsContainer = [UIView new];

    [self addSubview:self.callControlsContainer];
}

- (void)createVideoButton
{
    self.videoButton = [self createCircularButtonWithImageName:@"call-video" action:@selector(videoButtonPressed)];

    [self.callControlsContainer addSubview:self.videoButton];
}

- (void)createMicrophoneButton
{
    self.microphoneButton = [self createCircularButtonWithImageName:@"call-microphone-disable" action:@selector(micButtonPressed)];

    [self.callControlsContainer addSubview:self.microphoneButton];
}

- (void)createSpeakerButton
{
    self.speakerButton = [self createCircularButtonWithImageName:@"call-audio-enable" action:@selector(speakerButtonPressed)];

    [self.callControlsContainer addSubview:self.speakerButton];
}

- (void)createResumeButton
{
    self.resumeButton = [self createCircularButtonWithImageName:@"call-pause" action:@selector(resumeButtonPressed)];
    self.resumeButton.tintColor = [[AppContext sharedContext].appearance callRedColor];
    self.resumeButton.layer.borderColor = [[AppContext sharedContext].appearance callRedColor].CGColor;
    self.resumeButton.hidden = YES;

    [self.callControlsContainer addSubview:self.resumeButton];
}

- (void)installConstraints
{
    [self.callControlsContainer makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.right.equalTo(self).with.offset(-kIndent);
        make.left.equalTo(self).with.offset(kIndent);
        make.bottom.equalTo(self.endCallButton.top).with.offset(-kControlsContainerSpaceFromEndCall);
    }];

    [self.videoButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.callControlsContainer);
        make.height.equalTo(self.videoButton.width);
        make.bottom.equalTo(self.microphoneButton.top).with.offset(-k3ButtonGap);

        self.videoHorizontalConstraint = make.centerX.equalTo(self.callControlsContainer);
    }];

    [self.resumeButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.videoButton.left).with.offset(-k3ButtonGap);
        make.centerY.equalTo(self.videoButton);
        make.size.equalTo(self.videoButton);
    }];

    [self.microphoneButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.callControlsContainer);
        make.size.equalTo(self.videoButton);
        make.bottom.equalTo(self.callControlsContainer);
    }];

    [self.speakerButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.callControlsContainer);
        make.size.equalTo(self.videoButton);
        make.centerY.equalTo(self.microphoneButton);
    }];

    [self.endCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).with.offset(-kIndent);
        make.left.equalTo(self).with.offset(kIndent);
        make.right.equalTo(self).with.offset(-kIndent);
        make.height.equalTo(kEndCallButtonHeight);
    }];

}

- (void)createEndCallButton
{
    self.endCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.endCallButton.backgroundColor = [[AppContext sharedContext].appearance callRedColor];
    [self.endCallButton addTarget:self action:@selector(endCallButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.endCallButton.layer.cornerRadius = kEndCallButtonHeight / 2.0f;

    UIImage *image = [UIImage imageNamed:@"call-decline"];
    [self.endCallButton setImage:image forState:UIControlStateNormal];
    self.endCallButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.endCallButton.layer.borderWidth = kButtonBorderWidth;
    self.endCallButton.tintColor = [UIColor whiteColor];

    [self addSubview:self.endCallButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutIfNeeded];
    [self updateCornerRadius];
}

#pragma mark - Public
- (void)mainControlsHide:(BOOL)hide
{
    if (self.hidden) {
        return;
    }

    self.videoButton.hidden = hide;
    self.microphoneButton.hidden = hide;
    self.speakerButton.hidden = hide;
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

#pragma mark - CallControslViewProtocol

- (void)setMicSelected:(BOOL)micSelected
{
    self.microphoneButton.selected = micSelected;

    [self setButton:self.microphoneButton selected:micSelected];
}

- (BOOL)micSelected
{
    return self.microphoneButton.selected;
}

- (void)setSpeakerSelected:(BOOL)speakerSelected
{
    self.speakerButton.selected = speakerSelected;

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
    NSAssert(NO, @"Video button should never be set here");
}

- (BOOL)videoButtonSelected
{
    NSAssert(NO, @"Video button selected should not be checked here");
    return NO;
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
