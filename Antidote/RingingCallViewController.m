//
//  RingingCallViewController.m
//  Antidote
//
//  Created by Chuong Vu on 7/2/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "RingingCallViewController.h"
#import "Masonry.h"
#import "AvatarsManager.h"
#import "AppearanceManager.h"

static const CGFloat kIndent = 50.0;
static const CGFloat kButtonHeight = 70.0;
static const CGFloat kButtonWidth = 90.0;
static const CGFloat kButtonBorderWidth = 1.0;
static const CGFloat kAvatarDiameter = 180.0;
static const CGFloat kLabelFontSize = 16.0;

@interface RingingCallViewController ()

@property (strong, nonatomic) UIImageView *friendAvatar;
@property (strong, nonatomic) UILabel *incomingCallLabel;

@property (strong, nonatomic) UIView *declineContainer;
@property (strong, nonatomic) UIButton *declineCallButton;
@property (strong, nonatomic) UILabel *declineLabel;

@property (strong, nonatomic) UIView *acceptContainer;
@property (strong, nonatomic) UIButton *acceptCallButton;
@property (strong, nonatomic) UILabel *answerLabel;

@end

@implementation RingingCallViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createAcceptCallButton];
    [self createDeclineCallButton];
    [self createFriendAvatar];
    [self createIncomingCallLabel];

    [self installConstraints];
}

- (void)createFriendAvatar
{
    AvatarsManager *avatars = [AppContext sharedContext].avatars;

    UIImage *image = [avatars avatarFromString:self.nickname
                                      diameter:kAvatarDiameter
                                     textColor:[UIColor whiteColor]
                               backgroundColor:[UIColor clearColor]];

    self.friendAvatar = [[UIImageView alloc] initWithImage:image];

    [self.view addSubview:self.friendAvatar];
}

- (void)installConstraints
{
    [super installConstraints];

    [self.declineContainer makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).with.offset(kIndent);
        make.height.equalTo(kButtonHeight * 1.5);
        make.width.equalTo(kButtonWidth);
        make.bottom.equalTo(self.view.bottom).with.offset(-kIndent);
    }];

    [self.declineCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.declineContainer);
        make.bottom.equalTo(self.declineContainer);
        make.width.equalTo(kButtonWidth);
        make.height.equalTo(kButtonHeight);
    }];

    [self.acceptCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.acceptContainer);
        make.bottom.equalTo(self.acceptContainer);
        make.width.equalTo(kButtonWidth);
        make.height.equalTo(kButtonHeight);
    }];

    [self.acceptContainer makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.right).with.offset(-kIndent);
        make.height.equalTo(kButtonHeight * 1.5);
        make.width.equalTo(kButtonWidth);
        make.bottom.equalTo(self.view.bottom).with.offset(-kIndent);
    }];

    [self.declineLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.declineCallButton);
        make.bottom.equalTo(self.declineCallButton.top);
    }];

    [self.answerLabel makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.acceptCallButton.top);
        make.centerX.equalTo(self.acceptCallButton);
    }];

    [self.friendAvatar makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
    }];
}

#pragma mark - View setup

- (void)createAcceptCallButton
{
    self.acceptCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.acceptCallButton.tintColor = [UIColor whiteColor];
    self.acceptCallButton.backgroundColor = [[AppContext sharedContext].appearance callGreenColor];
    self.acceptCallButton.layer.cornerRadius = kButtonHeight / 2.0f;
    self.acceptCallButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.acceptCallButton.layer.borderWidth = kButtonBorderWidth;
    [self.acceptCallButton setImage:[UIImage imageNamed:@"call-phone"] forState:UIControlStateNormal];
    [self.acceptCallButton addTarget:self action:@selector(acceptCallButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    self.answerLabel = [UILabel new];
    self.answerLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:kLabelFontSize];
    self.answerLabel.textColor = [UIColor whiteColor];
    self.answerLabel.text = NSLocalizedString(@"Answer", @"Calls");

    self.acceptContainer = [UIView new];
    [self.acceptContainer addSubview:self.acceptCallButton];
    [self.acceptContainer addSubview:self.answerLabel];

    [self.view addSubview:self.acceptContainer];
}

- (void)createDeclineCallButton
{
    self.declineCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.declineCallButton.tintColor = [UIColor whiteColor];
    self.declineCallButton.backgroundColor = [[AppContext sharedContext].appearance callRedColor];
    self.declineCallButton.layer.cornerRadius = kButtonHeight / 2.0f;
    self.declineCallButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.declineCallButton.layer.borderWidth = kButtonBorderWidth;
    [self.declineCallButton setImage:[UIImage imageNamed:@"call-decline"] forState:UIControlStateNormal];
    [self.declineCallButton addTarget:self action:@selector(declineCallButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    self.declineLabel = [UILabel new];
    self.declineLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:kLabelFontSize];
    self.declineLabel.textColor = [UIColor whiteColor];
    self.declineLabel.text = NSLocalizedString(@"Decline", @"Calls");

    self.declineContainer = [UIView new];
    [self.declineContainer addSubview:self.declineCallButton];
    [self.declineContainer addSubview:self.declineLabel];

    [self.view addSubview:self.declineContainer];
}

- (void)createIncomingCallLabel
{
    self.subLabel.text = NSLocalizedString(@"incoming call", @"Calls");
}

#pragma mark - Touch actions

- (void)acceptCallButtonPressed
{
    [self.delegate ringingCallAnswerButtonPressed:self];
}

- (void)declineCallButtonPressed
{
    [self.delegate ringingCallDeclineButtonPressed:self];
}


@end
