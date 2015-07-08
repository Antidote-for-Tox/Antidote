//
//  RingingCallViewController.m
//  Antidote
//
//  Created by Chuong Vu on 7/2/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "RingingCallViewController.h"
#import "OCTSubmanagerCalls.h"
#import "ActiveCallViewController.h"
#import "Masonry.h"
#import "OCTCall.h"
#import "AvatarsManager.h"

static const CGFloat kIndent = 50.0;
static const CGFloat kButtonSize = 50.0;
static const CGFloat kAvatarDiameter = 180.0;

@interface RingingCallViewController ()

@property (strong, nonatomic) UIButton *acceptCallButton;
@property (strong, nonatomic) UIButton *declineCallButton;
@property (strong, nonatomic) UIImageView *friendAvatar;

@end

@implementation RingingCallViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.acceptCallButton = [UIButton new];
    self.acceptCallButton.backgroundColor = [UIColor greenColor];
    [self.acceptCallButton setImage:[UIImage imageNamed:@"call-accept"] forState:UIControlStateNormal];
    [self.acceptCallButton addTarget:self action:@selector(acceptCallButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.acceptCallButton];

    self.declineCallButton = [UIButton new];
    self.declineCallButton.backgroundColor = [UIColor redColor];
    [self.declineCallButton setImage:[UIImage imageNamed:@"call-decline"] forState:UIControlStateNormal];
    [self.declineCallButton addTarget:self action:@selector(declineCallButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.declineCallButton];

    [self createFriendAvatar];

    [self installConstraints];
}

- (void)createFriendAvatar
{
    AvatarsManager *avatars = [AppContext sharedContext].avatars;

    OCTFriend *friend = [self.call.chat.friends firstObject];

    UIImage *image = [avatars createAvatarFromString:friend.nickname
                                            diameter:kAvatarDiameter
                                           textColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor]];

    self.friendAvatar = [[UIImageView alloc] initWithImage:image];

    [self.view addSubview:self.friendAvatar];
}

- (void)installConstraints
{
    [super installConstraints];

    [self.acceptCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).with.offset(kIndent);
        make.height.equalTo(kButtonSize);
        make.width.equalTo(kButtonSize);
        make.centerY.equalTo(self.view.centerY).with.offset(kIndent);
    }];

    [self.declineCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.right).with.offset(-kIndent);
        make.height.equalTo(kButtonSize);
        make.width.equalTo(kButtonSize);
        make.centerY.equalTo(self.view.centerY).with.offset(kIndent);
    }];

    [self.friendAvatar makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
    }];
}

#pragma mark - Actions

- (void)acceptCallButtonPressed
{
    if (! [self.manager answerCall:self.call enableAudio:YES enableVideo:NO error:nil]) {
        return;
    }

    ActiveCallViewController *activeViewController = [[ActiveCallViewController alloc] initWithCall:self.call submanagerCalls:self.manager];

    [self.navigationController pushViewController:activeViewController animated:YES];
}

- (void)declineCallButtonPressed
{
    [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:self.call error:nil];
}

@end
