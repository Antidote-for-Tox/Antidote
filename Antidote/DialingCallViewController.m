//
//  DialingCallViewController.m
//  Antidote
//
//  Created by Chuong Vu on 7/1/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "DialingCallViewController.h"
#import "Masonry.h"
#import "Helper.h"
#import "AvatarsManager.h"
#import "AppearanceManager.h"

static const CGFloat kIndent = 50.0;
static const CGFloat kAvatarDiameter = 180.0;
static const CGFloat kButtonBorderWidth = 1.5f;
static const CGFloat kEndCallButtonHeight = 45.0;

@interface DialingCallViewController ()

@property (strong, nonatomic) UIButton *cancelCallButton;
@property (strong, nonatomic) UIImageView *friendAvatar;

@end

@implementation DialingCallViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createEndCallButton];
    [self createFriendAvatar];
    [self createReachingLabel];

    [self installConstraints];
}

#pragma mark - Public

- (void)setNickname:(NSString *)nickname
{
    [super setNickname:nickname];

    [self updateFriendAvatar];
}
#pragma mark - Private


- (void)createEndCallButton
{
    self.cancelCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelCallButton.backgroundColor = [[AppContext sharedContext].appearance callRedColor];
    [self.cancelCallButton addTarget:self action:@selector(cancelCallButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.cancelCallButton.layer.cornerRadius = kEndCallButtonHeight / 2.0f;

    UIImage *image = [UIImage imageNamed:@"call-decline"];
    [self.cancelCallButton setImage:image forState:UIControlStateNormal];
    self.cancelCallButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.cancelCallButton.layer.borderWidth = kButtonBorderWidth;
    self.cancelCallButton.tintColor = [UIColor whiteColor];

    [self.view addSubview:self.cancelCallButton];
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

- (void)updateFriendAvatar
{
    AvatarsManager *avatars = [AppContext sharedContext].avatars;

    UIImage *image = [avatars avatarFromString:self.nickname
                                      diameter:kAvatarDiameter
                                     textColor:[UIColor whiteColor]
                               backgroundColor:[UIColor clearColor]];

    [self.friendAvatar setImage:image];
}

- (void)createReachingLabel
{
    self.subLabel.text = NSLocalizedString(@"reaching...", @"Calls");

}

- (void)installConstraints
{
    [super installConstraints];

    [self.friendAvatar makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
    }];

    [self.cancelCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(kEndCallButtonHeight);
        make.bottom.equalTo(self.view).with.offset(-kIndent);
        make.left.equalTo(self.view).with.offset(kIndent);
        make.right.equalTo(self.view).with.offset(-kIndent);
    }];
}

#pragma mark - Touch actions

- (void)cancelCallButtonPressed
{
    [self.delegate dialingCallDeclineButtonPressed:self];
}
@end
