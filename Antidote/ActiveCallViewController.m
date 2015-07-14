//
//  ActiveCallViewController.m
//  Antidote
//
//  Created by Chuong Vu on 7/2/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ActiveCallViewController.h"
#import "Masonry.h"
#import "NSString+Utilities.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kIndent = 50.0;
static const CGFloat kIndentBetweenNameLabelTimer = 20.0;
static const CGFloat kButtonSide = 75.0;
static const CGFloat kEndCallButtonHeight = 45.0;
static const CGFloat kButtonBorderWidth = 1.5f;
static const CGFloat k3ButtonGap = 30.0;

@interface ActiveCallViewController ()

@property (strong, nonatomic) UILabel *timerLabel;
@property (strong, nonatomic) UIButton *endCallButton;
@property (strong, nonatomic) UIButton *videoButton;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIButton *microphoneButton;
@property (strong, nonatomic) UIButton *muteButton;
@property (strong, nonatomic) UIView *incomingCallContainer;

@end

@implementation ActiveCallViewController

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createEndCallButton];
    [self createCallTimer];
    [self createVideoButton];
    [self createContainerView];
    [self createMicrophoneButton];
    [self createMuteButton];

    [self installConstraints];
}

#pragma mark - View setup

- (void)createEndCallButton
{
    self.endCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.endCallButton.backgroundColor = [UIColor redColor];
    [self.endCallButton addTarget:self action:@selector(endCurrentCall) forControlEvents:UIControlEventTouchUpInside];
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
    self.videoButton = [self createButtonWithImageName:@"call-video" action:nil];

    [self.view addSubview:self.videoButton];
}

- (void)createContainerView
{
    self.containerView = [UIView new];
    [self.view addSubview:self.containerView];
}

- (void)createMicrophoneButton
{
    self.microphoneButton = [self createButtonWithImageName:@"call-microphone-enable" action:@selector(toggleMicrophone)];

    UIImage *selectedImage = [UIImage imageNamed:@"call-microphone-disable"];
    [self.microphoneButton setImage:selectedImage forState:UIControlStateSelected];

    [self.containerView addSubview:self.microphoneButton];
}

- (void)createMuteButton
{
    self.muteButton = [self createButtonWithImageName:@"call-audio-enable" action:@selector(toggleMute)];

    UIImage *selectedImage = [UIImage imageNamed:@"call-audio-disable"];
    [self.muteButton setImage:selectedImage forState:UIControlStateSelected];

    [self.containerView addSubview:self.muteButton];
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

    [self.containerView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.videoButton.bottom).with.offset(k3ButtonGap);
        make.centerX.equalTo(self.view);
        make.height.equalTo(kButtonSide);
    }];

    [self.microphoneButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView.left);
        make.right.equalTo(self.muteButton.left).with.offset(-k3ButtonGap);
        make.width.equalTo(kButtonSide);
        make.height.equalTo(kButtonSide);
        make.centerY.equalTo(self.containerView);
    }];

    [self.muteButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.containerView.right);
        make.width.equalTo(kButtonSide);
        make.height.equalTo(kButtonSide);
        make.centerY.equalTo(self.containerView);
    }];

}

#pragma mark - Private

- (void)setCallDuration:(NSTimeInterval)callDuration
{
    [super setCallDuration:callDuration];
    [self updateTimerLabel];
}

- (void)updateTimerLabel
{
    self.timerLabel.text = [NSString stringFromTimeInterval:self.callDuration];

    [self.timerLabel setNeedsDisplay];
}

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

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval
{
    int minutes = (int)interval / 60;
    int seconds = interval - (minutes * 60);

    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (void)toggleMicrophone
{
    BOOL enabled = ! self.delegate.enableMicrophone;
    self.delegate.enableMicrophone = enabled;
    self.microphoneButton.selected = ! enabled;
}

- (void)toggleMute
{
    NSError *error;

    if (self.muteButton.selected) {
        if ([self.delegate sendCallControl:OCTToxAVCallControlUnmuteAudio error:&error]) {
            self.muteButton.selected = NO;
        }
        else if (error.code == OCTToxAVErrorControlInvaldTransition) {
            self.muteButton.selected = YES;
        }
    }
    else {
        if ([self.delegate sendCallControl:OCTToxAVCallControlUnmuteAudio error:&error]) {
            self.muteButton.selected = YES;
        }
        else if (error.code == OCTToxAVErrorControlInvaldTransition) {
            self.muteButton.selected = NO;
        }
    }
}

- (void)incomingCallFromFriend:(NSString *)nickname
{
    self.incomingCallContainer = [UIView new];
    self.incomingCallContainer.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.incomingCallContainer];

    UILabel *nameLabel = [UILabel new];
    nameLabel.text = nickname;
    [self.incomingCallContainer addSubview:nameLabel];

    UIButton *declineCall = [UIButton buttonWithType:UIButtonTypeCustom];
    declineCall.backgroundColor = [UIColor redColor];
    [self.incomingCallContainer addSubview:declineCall];

    UIButton *acceptCall = [UIButton buttonWithType:UIButtonTypeCustom];
    acceptCall.backgroundColor = [UIColor greenColor];
    [self.incomingCallContainer addSubview:acceptCall];

    [self.incomingCallContainer makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(kButtonSide);
        make.bottom.equalTo(self.endCallButton.top).with.offset(-kIndent);
    }];
}

@end
