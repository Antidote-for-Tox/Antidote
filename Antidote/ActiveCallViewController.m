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
    [self.endCallButton setImage:[UIImage imageWithContentsOfFile:@"phone"] forState:UIControlStateNormal];
    [self.endCallButton addTarget:self action:@selector(endCall) forControlEvents:UIControlEventTouchUpInside];

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
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(kIndent);
        make.left.equalTo(self.nameLabel.mas_left);
        make.right.equalTo(self.nameLabel.mas_right);
        make.centerX.equalTo(self.nameLabel.centerX);
    }];

    [self.endCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-kIndent);
        make.centerX.equalTo(self.view.mas_centerX);
        make.left.equalTo(self.view.mas_left).with.offset(kIndent);
        make.right.equalTo(self.view.mas_right).with.offset(-kIndent);
    }];
}

#pragma mark - Private

- (void)didUpdateCall
{
    [super didUpdateCall];
    [self updateTimerLabel];
}

- (void)endCall
{}

- (void)updateTimerLabel
{
    self.timerLabel.text = [self stringFromTimeInterval:self.call.callDuration];
    [self.timerLabel setNeedsDisplay];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval
{
    int minutes = (int)interval / 60;
    int seconds = interval - (minutes * 60);

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;

    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}
@end
