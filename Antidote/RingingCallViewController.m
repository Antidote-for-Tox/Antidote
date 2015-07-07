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

static const CGFloat kIndent = 50.0;
static const CGFloat kButtonSize = 50.0;
static const CGFloat kIndentBelowNameLabel = 10.0;

@interface RingingCallViewController ()

@property (strong, nonatomic) UIButton *acceptCallButton;
@property (strong, nonatomic) UIButton *declineCallButton;

@property (strong, nonatomic) UILabel *incomingCallLabel;

@end

@implementation RingingCallViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createAcceptCallButton];
    [self createDeclineCallButton];
    [self createIncomingCallLabel];

    [self installConstraints];
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

    [self.incomingCallLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.bottom).with.offset(kIndentBelowNameLabel);
        make.centerX.equalTo(self.view.centerX);
    }];
}

#pragma mark - View setup

- (void)createAcceptCallButton
{
    self.acceptCallButton = [UIButton new];
    self.acceptCallButton.backgroundColor = [UIColor greenColor];
    [self.acceptCallButton setImage:[UIImage imageNamed:@"call-accept"] forState:UIControlStateNormal];
    [self.acceptCallButton addTarget:self action:@selector(acceptCallButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.acceptCallButton];
}

- (void)createDeclineCallButton
{
    self.declineCallButton = [UIButton new];
    self.declineCallButton.backgroundColor = [UIColor redColor];
    [self.declineCallButton setImage:[UIImage imageNamed:@"call-decline"] forState:UIControlStateNormal];
    [self.declineCallButton addTarget:self action:@selector(endCall) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.declineCallButton];
}

- (void)createIncomingCallLabel
{
    self.incomingCallLabel = [UILabel new];
    self.incomingCallLabel.text = @"incoming call";
    self.incomingCallLabel.textColor = [UIColor whiteColor];

    [self.view addSubview:self.incomingCallLabel];
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


@end
