//
//  PauseCallCellTableViewCell.m
//  Antidote
//
//  Created by Chuong Vu on 7/16/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "PauseCallTableViewCell.h"
#import "AppearanceManager.h"
#import "NSString+Utilities.h"
#import "Masonry.h"

static const CGFloat kEndCallButtonSize = 30.0;
static const CGFloat kNickNameFontSize = 16.0;
static const CGFloat kCallDurationFontSize = 11.0;

@interface PauseCallTableViewCell ()

@property (strong, nonatomic) UIButton *endCallButton;
@end

@implementation PauseCallTableViewCell

#pragma mark - LifeCycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];

    if (! self) {
        return nil;
    }

    self.backgroundColor = [UIColor blackColor];

    [self setImageViewToPauseImage];
    [self createEndCallButton];
    [self setupFont];
    [self installConstraints];

    return self;
}

#pragma mark - View setup

- (void)createEndCallButton
{
    UIImage *image = [UIImage imageNamed:@"call-decline"];

    self.endCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.endCallButton setBackgroundImage:image forState:UIControlStateNormal];
    self.endCallButton.tintColor = [UIColor whiteColor];
    self.endCallButton.backgroundColor = [[AppContext sharedContext].appearance callRedColor];
    self.endCallButton.layer.cornerRadius = kEndCallButtonSize / 2.0;

    [self.endCallButton addTarget:self action:@selector(endCallButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    [self.contentView addSubview:self.endCallButton];
}

- (void)setImageViewToPauseImage
{
    UIImage *image = [UIImage imageNamed:@"call-pause"];

    [self.imageView setImage:image];
    self.imageView.tintColor = [UIColor whiteColor];
}

- (void)setupFont
{
    self.textLabel.textAlignment = NSTextAlignmentLeft;

    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueBoldWithSize:kNickNameFontSize];

    self.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    self.detailTextLabel.textColor = [UIColor whiteColor];
    self.detailTextLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueBoldWithSize:kCallDurationFontSize];
}

- (void)installConstraints
{
    [self.endCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.rightMargin);
        make.size.equalTo(kEndCallButtonSize);
        make.centerY.equalTo(self.contentView);
    }];

    [self.textLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView.right).with.offset(10.0);
        make.right.lessThanOrEqualTo(self.endCallButton.left);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.centerY);
    }];

    [self.detailTextLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView.right).with.offset(10.0);
        make.right.lessThanOrEqualTo(self.endCallButton.left);
        make.top.equalTo(self.contentView.centerY);
        make.bottom.equalTo(self.contentView);
    }];
}

#pragma mark - Public

- (void)setCallerNickname:(NSString *)nickName andOnHoldDuration:(NSTimeInterval)callDuration
{
    self.textLabel.text = nickName;

    NSString *onHold = NSLocalizedString(@"on hold", @"Calls");
    NSString *time = [NSString stringFromTimeInterval:callDuration];

    self.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", onHold, time];
}

#pragma mark - Private

- (void)endCallButtonTapped
{
    [self.delegate pauseCallCellEndPausedCallButtonTapped:self];
}

@end
