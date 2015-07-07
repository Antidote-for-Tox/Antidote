//
//  ActiveCallViewController.m
//  Antidote
//
//  Created by Chuong Vu on 7/2/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ActiveCallViewController.h"
#import "Masonry.h"
#import "OCTCall.h"
#import "OCTSubmanagerCalls.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kIndent = 50.0;
static const CGFloat kIndentBetweenNameLabelTimer = 20.0;
static const CGFloat kButtonSide = 75.0;
static const CGFloat kEndCallButtonHeight = 45.0;
static const CGFloat kButtonBorderWidth = 1.5f;

@interface ActiveCallViewController ()

@property (strong, nonatomic) UILabel *timerLabel;
@property (strong, nonatomic) UIButton *endCallButton;
@property (strong, nonatomic) UIButton *videoButton;
@property (strong, nonatomic) UIButton *microphoneButton;
@property (strong, nonatomic) UIButton *muteButton;

@property (nonatomic, assign) BOOL audioIsMuted;

@end

@implementation ActiveCallViewController

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createEndCallButton];
    [self createCallTimer];
    [self createVideoButton];
    [self createMicrophoneButton];
    [self createMuteButton];

    [self installConstraints];
}

#pragma mark - View setup

- (void)createEndCallButton
{
    self.endCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.endCallButton.backgroundColor = [UIColor redColor];
    [self.endCallButton addTarget:self action:@selector(endCall) forControlEvents:UIControlEventTouchUpInside];
    self.endCallButton.layer.cornerRadius = kEndCallButtonHeight / 2.0f;

    UIImage *image = [UIImage imageNamed:@"call-accept"];
    [self.endCallButton setImage:image forState:UIControlStateNormal];
    self.endCallButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.endCallButton.layer.borderWidth = kButtonBorderWidth;
    self.endCallButton.tintColor = [UIColor whiteColor];

    [self.view addSubview:self.endCallButton];
}

- (void)createCallTimer
{
    self.timerLabel = [UILabel new];
    self.timerLabel.textColor = [UIColor whiteColor];
    self.timerLabel.textAlignment = NSTextAlignmentCenter;

    [self.view addSubview:self.timerLabel];
}

- (void)createVideoButton
{
    self.videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"call-video"];
    [self.videoButton setImage:image forState:UIControlStateNormal];

    self.videoButton.tintColor = [UIColor whiteColor];

    self.videoButton.contentMode = UIViewContentModeScaleAspectFill;
    self.videoButton.layer.cornerRadius = kButtonSide / 2.0f;
    self.videoButton.layer.masksToBounds = YES;
    self.videoButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.videoButton.layer.borderWidth = kButtonBorderWidth;

    [self.view addSubview:self.videoButton];
}

- (void)createMicrophoneButton
{
    self.microphoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"call-microphone-enable"];
    [self.microphoneButton setImage:image forState:UIControlStateNormal];

    self.microphoneButton.tintColor = [UIColor whiteColor];

    self.microphoneButton.contentMode = UIViewContentModeScaleAspectFill;
    self.microphoneButton.layer.cornerRadius = kButtonSide / 2.0f;
    self.microphoneButton.layer.masksToBounds = YES;
    self.microphoneButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.microphoneButton.layer.borderWidth = kButtonBorderWidth;

    [self.microphoneButton addTarget:self action:@selector(toggleMicrophone) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.microphoneButton];
}

- (void)createMuteButton
{
    self.muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"call-audio-enable"];
    [self.muteButton setImage:image forState:UIControlStateNormal];

    self.muteButton.tintColor = [UIColor whiteColor];

    self.muteButton.contentMode = UIViewContentModeScaleAspectFill;
    self.muteButton.layer.cornerRadius = kButtonSide / 2.0f;
    self.muteButton.layer.masksToBounds = YES;
    self.muteButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.muteButton.layer.borderWidth = kButtonBorderWidth;

    [self.muteButton addTarget:self action:@selector(toggleMute) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.muteButton];
}

- (void)installConstraints
{
    [super installConstraints];

    [self.timerLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.bottom).with.offset(kIndentBetweenNameLabelTimer);
        make.centerX.equalTo(self.nameLabel.centerX);
    }];

    [self.endCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.bottom).with.offset(-kIndent);
        make.left.equalTo(self.view.left).with.offset(kIndent);
        make.right.equalTo(self.view.right).with.offset(-kIndent);
        make.height.equalTo(kEndCallButtonHeight);
    }];

    [self.videoButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.centerY).with.offset(-kIndent);
        make.centerX.equalTo(self.view.centerX);
        make.width.equalTo(kButtonSide);
        make.height.equalTo(kButtonSide);
    }];

    [self.microphoneButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoButton.bottom).with.offset((1.0 / 6.0) * self.view.center.x);
        make.centerX.equalTo(self.view).with.offset(-(1.0/ 3.0) * self.view.center.x);
        make.width.equalTo(kButtonSide);
        make.height.equalTo(kButtonSide);
    }];

    [self.muteButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.microphoneButton);
        make.centerX.equalTo(self.view).with.offset((1.0 / 3.0) * self.view.center.x);
        make.width.equalTo(kButtonSide);
        make.height.equalTo(kButtonSide);
    }];
}

#pragma mark - Private

- (void)didUpdateCall
{
    [super didUpdateCall];
    [self updateTimerLabel];
}

- (void)updateTimerLabel
{
    self.timerLabel.text = [self stringFromTimeInterval:self.call.callDuration];
    [self.timerLabel setNeedsDisplay];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval
{
    int minutes = (int)interval / 60;
    int seconds = interval - (minutes * 60);

    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (void)toggleMicrophone
{
    if (self.manager.enableMicrophone) {
        self.manager.enableMicrophone = NO;

        UIImage *image = [UIImage imageNamed:@"call-microphone-disable"];
        [self.microphoneButton setImage:image forState:UIControlStateNormal];
    }
    else {
        self.manager.enableMicrophone = YES;
        UIImage *image = [UIImage imageNamed:@"call-microphone-enable"];
        [self.microphoneButton setImage:image forState:UIControlStateNormal];
    }
}

- (void)toggleMute
{
    NSError *error;

    if (self.audioIsMuted) {
        if ([self.manager sendCallControl:OCTToxAVCallControlUnmuteAudio toCall:self.call error:&error]) {
            self.audioIsMuted = NO;
        }
        else if (error.code == OCTToxAVErrorControlInvaldTransition) {
            self.audioIsMuted = YES;
        }
    }
    else {
        if ([self.manager sendCallControl:OCTToxAVCallControlMuteAudio toCall:self.call error:&error]) {
            self.audioIsMuted = YES;
        }
        else if (error.code == OCTToxAVErrorControlInvaldTransition) {
            self.audioIsMuted = NO;
        }
    }
}

- (void)setAudioIsMuted:(BOOL)audioIsMuted
{
    if (audioIsMuted) {
        UIImage *image = [UIImage imageNamed:@"call-audio-disable"];
        [self.muteButton setImage:image forState:UIControlStateNormal];
        _audioIsMuted = YES;
    }
    else {
        UIImage *image = [UIImage imageNamed:@"call-audio-enable"];
        [self.muteButton setImage:image forState:UIControlStateNormal];
        _audioIsMuted = NO;
    }
}
@end
