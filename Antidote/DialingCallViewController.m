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
#import "OCTCall.h"
#import "OCTChat.h"
#import "AvatarsManager.h"
#import "OCTSubmanagerCalls.h"
#import "ActiveCallViewController.h"

static const CGFloat kIndent = 50.0;
static const CGFloat kAvatarDiameter = 180.0;

@interface DialingCallViewController ()

@property (strong, nonatomic) UIButton *cancelCallButton;
@property (assign, nonatomic) dispatch_once_t becameActiveToken;
@property (strong, nonatomic) UIImageView *friendAvatar;

@end

@implementation DialingCallViewController

#pragma mark - Life cycle

- (instancetype)initWithChat:(OCTChat *)chat submanagerCalls:(OCTSubmanagerCalls *)manager
{
    OCTCall *call = [manager callToChat:chat enableAudio:YES enableVideo:NO error:nil];

    if (! call) {
        return nil;
    }

    self = [super initWithCall:call submanagerCalls:manager];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createEndCallButton];
    [self createFriendAvatar];
    [self installConstraints];
}

#pragma mark - Private


- (void)createEndCallButton
{
    self.cancelCallButton = [UIButton new];
    self.cancelCallButton.backgroundColor = [UIColor redColor];
    [self.cancelCallButton addTarget:self action:@selector(endCall) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.cancelCallButton];
}

- (void)createFriendAvatar
{
    AvatarsManager *avatars = [AppContext sharedContext].avatars;

    OCTFriend *friend = [self.call.chat.friends firstObject];
    UIImage *image = [avatars avatarFromString:friend.nickname
                                      diameter:kAvatarDiameter
                                     textColor:[UIColor whiteColor]
                               backgroundColor:[UIColor clearColor]];

    self.friendAvatar = [[UIImageView alloc] initWithImage:image];

    [self.view addSubview:self.friendAvatar];
}

- (void)installConstraints
{
    [super installConstraints];

    [self.friendAvatar makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
    }];

    [self.cancelCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.bottom).with.offset(-kIndent);
        make.left.equalTo(self.view.left).with.offset(kIndent);
        make.right.equalTo(self.view.right).with.offset(-kIndent);
    }];
}

#pragma mark - Call methods

- (void)didUpdateCall
{
    [super didUpdateCall];

    if (self.call.status == OCTCallStatusActive) {
        // workaround for deadlock in objcTox https://github.com/Antidote-for-Tox/objcTox/issues/51
        dispatch_once(&_becameActiveToken, ^{
            [self performSelector:@selector(pushToActiveCallController) withObject:nil afterDelay:0];
        });
    }
}
- (void)endCall
{
    [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:self.call error:nil];
}

- (void)pushToActiveCallController
{
    ActiveCallViewController *activeCallViewController = [[ActiveCallViewController alloc] initWithCall:self.call submanagerCalls:self.manager];

    [self.navigationController pushViewController:activeCallViewController animated:YES];
}

@end
