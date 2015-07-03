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

static const CGFloat kIndent = 50.0;

@interface ActiveCallViewController ()

@property (strong, nonatomic) UILabel *timerLabel;
@property (strong, nonatomic) UIButton *endCallButton;

@end

@implementation ActiveCallViewController

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createEndCallButton];
    [self createCallTimer];

    [self installConstraints];
}

- (void)createEndCallButton
{
    self.endCallButton = [UIButton new];
    self.endCallButton.backgroundColor = [UIColor redColor];
    [self.endCallButton addTarget:self action:@selector(endCallButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.endCallButton];
}

- (void)createCallTimer
{
    self.timerLabel = [UILabel new];
    self.timerLabel.textColor = [UIColor whiteColor];
    self.timerLabel.textAlignment = NSTextAlignmentCenter;

    [self.view addSubview:self.timerLabel];
}

- (void)installConstraints
{
    [super installConstraints];

    [self.timerLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.bottom).with.offset(kIndent);
        make.centerX.equalTo(self.nameLabel.centerX);
    }];

    [self.endCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.bottom).with.offset(-kIndent);
        make.left.equalTo(self.view.left).with.offset(kIndent);
        make.right.equalTo(self.view.right).with.offset(-kIndent);
    }];
}

#pragma mark - Private

- (void)didUpdateCall
{
    [super didUpdateCall];
    [self updateTimerLabel];
}

- (void)endCallButtonPressed
{
    [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:self.call error:nil];
}

- (void)updateTimerLabel
{
    self.timerLabel.text = [self stringFromTimeInterval:self.call.callDuration];
    [self.timerLabel setNeedsDisplay];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval
{
    // See https://github.com/Antidote-for-Tox/objcTox/issues/55
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"HH:mm:ss"];

    return [dateFormatter stringFromDate:date];
}
@end
