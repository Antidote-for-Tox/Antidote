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
static const CGFloat kYEndCallPadding = 20.0;
static const CGFloat kButtonBorderWidth = 1.5f;
static const CGFloat kEndCallButtonHeight = 45.0;

@interface DialingCallViewController ()

@property (strong, nonatomic) UIButton *cancelCallButton;
@property (strong, nonatomic) UIImageView *friendAvatar;

@end

@implementation DialingCallViewController

#pragma mark - View setup

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createEndCallButton];
    [self createFriendAvatar];
    [self createReachingLabel];

    [self installConstraints];
}

- (void)viewDidLayoutSubviews
{
    [self updateFriendAvatar];
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
        make.bottom.equalTo(self.view).with.offset(-kYEndCallPadding);
        make.left.equalTo(self.view).with.offset(kIndent);
        make.right.equalTo(self.view).with.offset(-kIndent);
    }];
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
    self.friendAvatar = [UIImageView new];

    [self updateFriendAvatar];

    [self.view addSubview:self.friendAvatar];
}

- (void)updateFriendAvatar
{
    AvatarsManager *avatars = [AppContext sharedContext].avatars;

    CGFloat smallestSide = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
    CGFloat diameterOfImage = smallestSide / 2;

    UIImage *image = [avatars avatarFromString:self.nickname
                                      diameter:diameterOfImage
                                     textColor:[UIColor whiteColor]
                               backgroundColor:[UIColor clearColor]];

    [self.friendAvatar setImage:image];
}

- (void)createReachingLabel
{
    self.subLabel.text = NSLocalizedString(@"reaching...", @"Calls");

}

#pragma mark - Touch actions

- (void)cancelCallButtonPressed
{
    [self.delegate dialingCallDeclineButtonPressed:self];
}
@end
