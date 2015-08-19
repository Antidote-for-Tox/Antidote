//
//  CompactControlsView.m
//  Antidote
//
//  Created by Chuong Vu on 8/10/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "CompactControlsView.h"
#import "AppearanceManager.h"
#import "Masonry.h"

static const CGFloat kNotSelectedAlpha = 0.3;
static const CGFloat kSelectedAlpha = 1.0;

@interface CompactControlsView ()

@property (strong, nonatomic) UIButton *videoButton;
@property (strong, nonatomic) UIButton *microphoneButton;
@property (strong, nonatomic) UIButton *speakerButton;
@property (strong, nonatomic) UIButton *resumeButton;
@property (strong, nonatomic) UIButton *endCallButton;

@property (strong, nonatomic) UIView *spacing1;
@property (strong, nonatomic) UIView *spacing2;
@property (strong, nonatomic) UIView *spacing3;
@property (strong, nonatomic) UIView *spacing4;
@property (strong, nonatomic) UIView *spacing5;

@end

@implementation CompactControlsView

#pragma mark - Life cycle
- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    [self createVideoButton];
    [self createMicButton];
    [self createSpeakerButton];
    [self createEndCallButton];

    [self createSpacings];

    [self installConstraints];

    return self;
}

#pragma mark - View setup

- (void)createVideoButton
{
    self.videoButton = [self createCircularButtonWithImageName:@"call-video" action:@selector(videoButtonPressed)];
    [self addSubview:self.videoButton];
}

- (void)createMicButton
{
    self.microphoneButton = [self createCircularButtonWithImageName:@"call-microphone-disable" action:@selector(micButtonPressed)];

    [self addSubview:self.microphoneButton];
}

- (void)createSpeakerButton
{
    self.speakerButton = [self createCircularButtonWithImageName:@"call-audio-enable" action:@selector(speakerButtonPressed)];

    [self addSubview:self.speakerButton];
}

- (void)createResumeButton
{
    self.resumeButton = [self createCircularButtonWithImageName:@"call-pause" action:@selector(endCallButtonPressed)];

    [self addSubview:self.resumeButton];
}

- (void)createEndCallButton
{
    self.endCallButton = [self createCircularButtonWithImageName:@"call-decline" action:@selector(endCallButtonPressed)];
    self.endCallButton.backgroundColor = [[AppContext sharedContext].appearance callRedColor];
    self.endCallButton.alpha = kSelectedAlpha;
    self.endCallButton.tintColor = [UIColor whiteColor];

    [self addSubview:self.endCallButton];
}

- (void)createSpacings
{
    self.spacing1 = [UIView new];
    self.spacing2 = [UIView new];
    self.spacing3 = [UIView new];
    self.spacing4 = [UIView new];
    self.spacing5 = [UIView new];

    [self addSubview:self.spacing1];
    [self addSubview:self.spacing2];
    [self addSubview:self.spacing3];
    [self addSubview:self.spacing4];
    [self addSubview:self.spacing5];
}

#pragma mark - View setup
- (void)installConstraints
{
    [self.spacing1 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self.videoButton.left);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.width.equalTo(self.spacing2);
    }];

    [self.videoButton makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.videoButton.height);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];

    [self.spacing2 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.videoButton.right);
        make.right.equalTo(self.microphoneButton.left);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.width.equalTo(self.spacing3);
    }];

    [self.microphoneButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.videoButton);
        make.size.equalTo(self.videoButton);
    }];

    [self.spacing3 makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.speakerButton.left);
        make.left.equalTo(self.microphoneButton.right);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.width.equalTo(self.spacing4);
    }];

    [self.speakerButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.videoButton);
        make.size.equalTo(self.videoButton);
    }];

    [self.spacing4 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.speakerButton.right);
        make.right.equalTo(self.endCallButton.left);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.width.equalTo(self.spacing5);
    }];

    [self.endCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.videoButton);
        make.size.equalTo(self.videoButton);
    }];

    [self.spacing5 makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.left.equalTo(self.endCallButton.right);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.width.equalTo(self.spacing4);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateCornerRadius];
}

#pragma mark - CallControlsViewProtocol

- (void)setMicSelected:(BOOL)micSelected
{
    [self setButton:self.microphoneButton selected:micSelected];
}

- (BOOL)micSelected
{
    return self.microphoneButton.selected;
}

- (void)setSpeakerSelected:(BOOL)speakerSelected
{
    [self setButton:self.speakerButton selected:speakerSelected];
}

- (BOOL)speakerSelected
{
    return self.speakerButton.selected;
}

- (void)setResumeButtonHidden:(BOOL)resumeButtonHidden
{
    /** to do **/
}

- (BOOL)resumeButtonHidden
{
    /** to do **/
    return YES;
}

- (void)setVideoButtonSelected:(BOOL)videoButtonSelected
{
    [self setButton:self.videoButton selected:videoButtonSelected];
}

- (BOOL)videoButtonSelected
{
    return self.videoButton.selected;
}

#pragma mark - Touch Actions

- (void)videoButtonPressed
{
    [self.delegate callControlsVideoButtonPressed:self];
}

- (void)micButtonPressed
{
    [self.delegate callControlsMicButtonPressed:self];
}

- (void)speakerButtonPressed
{
    [self.delegate callControlsSpeakerButtonPressed:self];
}

- (void)endCallButtonPressed
{
    [self.delegate callControlsEndCallButtonPressed:self];
}

#pragma mark - Private

- (UIButton *)createCircularButtonWithImageName:(NSString *)imageName action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:imageName];
    button.backgroundColor = [UIColor whiteColor];
    [button setImage:image forState:UIControlStateNormal];
    button.tintColor = [UIColor blackColor];
    button.alpha = kNotSelectedAlpha;

    button.contentMode = UIViewContentModeScaleAspectFill;
    button.layer.masksToBounds = YES;

    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (void)setButton:(UIButton *)button selected:(BOOL)selected
{
    CGFloat newAlpha = selected ? kSelectedAlpha : kNotSelectedAlpha;
    button.alpha = newAlpha;
    button.selected = selected;
}

- (void)updateCornerRadius
{
    CGFloat newCornerRadius = self.videoButton.frame.size.height / 2.0;
    self.videoButton.layer.cornerRadius = newCornerRadius;
    self.microphoneButton.layer.cornerRadius = newCornerRadius;
    self.speakerButton.layer.cornerRadius = newCornerRadius;
    self.resumeButton.layer.cornerRadius = newCornerRadius;
    self.endCallButton.layer.cornerRadius = newCornerRadius;
}

@end
