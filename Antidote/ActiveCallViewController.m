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
#import "AppearanceManager.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kIndent = 50.0;
static const CGFloat kIndentBetweenNameLabelTimer = 20.0;
static const CGFloat kButtonSide = 75.0;
static const CGFloat kEndCallButtonHeight = 45.0;
static const CGFloat kButtonBorderWidth = 1.5f;
static const CGFloat k3ButtonGap = 30.0;
static const CGFloat kOtherCallButtonSize = 4.0 / 5.0 * kButtonSide;
static const CGFloat kIncomingNameFontSize = 12.0;
static const CGFloat kIncomingIsCallingFontSize = 10.0;

@interface ActiveCallViewController ()

@property (strong, nonatomic) UILabel *timerLabel;
@property (strong, nonatomic) UIButton *endCallButton;
@property (strong, nonatomic) UIButton *videoButton;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIButton *microphoneButton;
@property (strong, nonatomic) UIButton *speakerButton;
@property (strong, nonatomic) UIView *incomingCallContainer;

@end

@implementation ActiveCallViewController

@dynamic delegate;

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
    [self.endCallButton addTarget:self action:@selector(endCallButtonPressed) forControlEvents:UIControlEventTouchUpInside];
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
    self.microphoneButton = [self createButtonWithImageName:@"call-microphone-enable" action:@selector(micButtonPressed)];

    UIImage *selectedImage = [UIImage imageNamed:@"call-microphone-disable"];
    [self.microphoneButton setImage:selectedImage forState:UIControlStateSelected];

    [self.containerView addSubview:self.microphoneButton];
}

- (void)createMuteButton
{
    self.speakerButton = [self createButtonWithImageName:@"call-audio-enable" action:@selector(speakerButtonPressed)];

    UIImage *selectedImage = [UIImage imageNamed:@"call-audio-disable"];
    [self.speakerButton setImage:selectedImage forState:UIControlStateSelected];

    [self.containerView addSubview:self.speakerButton];
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
        make.right.equalTo(self.speakerButton.left).with.offset(-k3ButtonGap);
        make.width.equalTo(kButtonSide);
        make.height.equalTo(kButtonSide);
        make.centerY.equalTo(self.containerView);
    }];

    [self.speakerButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.containerView.right);
        make.width.equalTo(kButtonSide);
        make.height.equalTo(kButtonSide);
        make.centerY.equalTo(self.containerView);
    }];

}

#pragma mark - Public

- (void)setCallDuration:(NSTimeInterval)callDuration
{
    _callDuration = callDuration;
    [self updateTimerLabel];
}

- (void)setMicSelected:(BOOL)micSelected
{
    self.microphoneButton.selected = micSelected;
}

- (BOOL)micSelected
{
    return self.microphoneButton.selected;
}

- (void)setSpeakerSelected:(BOOL)speakerSelected
{
    self.speakerButton.selected = speakerSelected;
}

- (BOOL)speakerSelected
{
    return self.speakerButton.selected;
}

- (void)setCreateIncomingCallView:(BOOL)createIncomingCallView
{
    if (createIncomingCallView) {
        [self setupIncomingCallView];
    }
    else {
        [self.incomingCallContainer removeFromSuperview];
        self.incomingCallContainer = nil;
        self.incomingCallCallerName = nil;
    }

    _createIncomingCallView = createIncomingCallView;
}

#pragma mark - Private

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

- (void)setupIncomingCallView
{
    self.incomingCallContainer = [UIView new];
    self.incomingCallContainer.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.incomingCallContainer];

    UILabel *nameLabel = [UILabel new];
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = self.incomingCallCallerName;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueBoldWithSize:kIncomingNameFontSize];
    [self.incomingCallContainer addSubview:nameLabel];

    UILabel *descriptionLabel = [UILabel new];
    descriptionLabel.text = NSLocalizedString(@"is calling", @"Calls");
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueBoldWithSize:kIncomingIsCallingFontSize];
    [self.incomingCallContainer addSubview:descriptionLabel];

    UIButton *declineCall = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *declineCallImage = [UIImage imageNamed:@"call-accept"];
    [declineCall setImage:declineCallImage forState:UIControlStateNormal];
    declineCall.tintColor = [UIColor whiteColor];
    declineCall.backgroundColor = [UIColor redColor];
    declineCall.layer.cornerRadius = kOtherCallButtonSize / 2.0;
    [declineCall addTarget:self action:@selector(declineIncomingCallButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.incomingCallContainer addSubview:declineCall];

    UIButton *acceptCall = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *acceptCallimage = [UIImage imageNamed:@"call-phone"];
    [acceptCall setImage:acceptCallimage forState:UIControlStateNormal];
    acceptCall.tintColor = [UIColor whiteColor];
    acceptCall.backgroundColor = [UIColor greenColor];
    acceptCall.layer.cornerRadius = kOtherCallButtonSize / 2.0;
    [acceptCall addTarget:self action:@selector(acceptIncomingCallButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.incomingCallContainer addSubview:acceptCall];

    [self.incomingCallContainer makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(kButtonSide);
        make.bottom.equalTo(self.endCallButton.top).with.offset(-kIndent);
    }];

    [acceptCall makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.incomingCallContainer);
        make.centerY.equalTo(self.incomingCallContainer);
        make.height.equalTo(kOtherCallButtonSize);
        make.width.equalTo(kOtherCallButtonSize);
    }];

    [declineCall makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(acceptCall);
        make.centerY.equalTo(acceptCall);
        make.right.equalTo(acceptCall.left).with.offset(-kIndent);
    }];

    [nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.incomingCallContainer.left);
        make.height.equalTo(20.0);
        make.bottom.equalTo(self.incomingCallContainer.centerY);
    }];

    [descriptionLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(nameLabel);
        make.bottom.equalTo(self.incomingCallContainer.bottom);
        make.top.equalTo(self.incomingCallContainer.centerY);
    }];
}

#pragma mark - Touch actions

- (void)acceptIncomingCallButtonPressed
{
    [self.delegate activeCallAnswerIncomingCallButtonPressed:self];
}

- (void)declineIncomingCallButtonPressed
{
    [self.delegate activeCallDeclineIncomingCallButtonPressed:self];
}

- (void)micButtonPressed
{
    [self.delegate activeCallMicButtonPressed:self];
}

- (void)speakerButtonPressed
{
    [self.delegate activeCallSpeakerButtonPressed:self];
}

- (void)endCallButtonPressed
{
    [self.delegate activeCallDeclineButtonPressed:self];
}

- (void)pauseSelectedCallAtIndex:(NSUInteger)index
{
    [self.delegate activeCallPausedCallSelectedAtIndex:index
                                            controller:self];
}

@end
