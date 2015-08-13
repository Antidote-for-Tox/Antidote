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

static const CGFloat kSpacing = 10.0;

@interface CompactControlsView ()

@property (strong, nonatomic) UIButton *videoButton;
@property (strong, nonatomic) UIButton *microphoneButton;
@property (strong, nonatomic) UIButton *speakerButton;
@property (strong, nonatomic) UIButton *resumeButton;
@property (strong, nonatomic) UIButton *endCallButton;

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

    [self installConstraints];

    return self;
}

#pragma mark - View setup

- (void)createVideoButton
{
    self.videoButton = [self createButtonWithImageName:@"call-video" action:@selector(videoButtonPressed)];
    [self addSubview:self.videoButton];
}

- (void)createMicButton
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
    self.resumeButton = [self createButtonWithImageName:@"call-pause" action:@selector(endCallButtonPressed)];

    [self addSubview:self.resumeButton];
}

- (void)createEndCallButton
{
    self.endCallButton = [self createButtonWithImageName:@"call-decline" action:@selector(endCallButtonPressed)];
    self.endCallButton.tintColor = [[AppContext sharedContext].appearance callRedColor];

    [self addSubview:self.endCallButton];
}

#pragma mark - View setup
- (void)installConstraints
{
    [self.videoButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(kSpacing);
        make.height.equalTo(self.videoButton.width);
    }];

    [self.microphoneButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.videoButton.right).with.offset(kSpacing);
        make.centerY.equalTo(self.videoButton);
        make.size.equalTo(self.videoButton);
    }];

    [self.speakerButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.microphoneButton.right).with.offset(kSpacing);
        make.centerY.equalTo(self.videoButton);
        make.size.equalTo(self.videoButton);
    }];

    [self.endCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.speakerButton.right).with.offset(kSpacing);
        make.right.equalTo(self).with.offset(-kSpacing);
        make.centerY.equalTo(self.videoButton);
        make.size.equalTo(self.videoButton);
    }];

    [self makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoButton);
        make.bottom.equalTo(self.videoButton);
    }];
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

- (UIButton *)createButtonWithImageName:(NSString *)imageName action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:imageName];
    [button setImage:image forState:UIControlStateNormal];
    button.tintColor = [UIColor grayColor];
    button.contentMode = UIViewContentModeScaleAspectFit;

    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (void)setButton:(UIButton *)button selected:(BOOL)selected
{
    if (selected) {
        button.tintColor = [UIColor whiteColor];
    }
    else {
        button.tintColor = [UIColor grayColor];
    }
}

@end
