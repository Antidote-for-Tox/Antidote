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
#import "OCTSubmanagerCalls.h"
#import "ActiveCallViewController.h"

static const CGFloat kIndent = 50.0;

@interface DialingCallViewController ()

@property (strong, nonatomic) UIButton *cancelCallButton;


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

    [self installConstraints];
}

#pragma mark - Private


- (void)createEndCallButton
{
    self.cancelCallButton = [UIButton new];
    self.cancelCallButton.backgroundColor = [UIColor redColor];
    [self.cancelCallButton setImage:[UIImage imageWithContentsOfFile:@"phone"] forState:UIControlStateNormal];
    [self.cancelCallButton addTarget:self action:@selector(endCall) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.cancelCallButton];
}

- (void)installConstraints
{
    [super installConstraints];

    [self.cancelCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-kIndent);
        make.centerX.equalTo(self.view.mas_centerX);
        make.left.equalTo(self.view.mas_left).with.offset(kIndent);
        make.right.equalTo(self.view.mas_right).with.offset(-kIndent);
    }];
}

#pragma mark - Call methods

- (void)didUpdateCall
{
    [super didUpdateCall];

    if (self.call.status == OCTCallStatusActive) {
        [self pushToActiveCallController];
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
