//
//  IncomingCallNotificationView.m
//  Antidote
//
//  Created by Chuong Vu on 7/21/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "IncomingCallNotificationView.h"
#import "AppearanceManager.h"
#import "Masonry.h"

static const CGFloat kIncomingNameFontSize = 12.0;
static const CGFloat kIncomingIsCallingFontSize = 10.0;
static const CGFloat kButtonSize = 50.0;
static const CGFloat kIndent = 30.0;

@interface IncomingCallNotificationView ()

@property (strong, nonatomic) NSString *nickname;

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UIButton *declineButton;
@property (strong, nonatomic) UIButton *acceptButton;

@end
@implementation IncomingCallNotificationView


#pragma mark - LifeCycle
- (instancetype)initWithNickname:(NSString *)nickname
{
    self = [super init];
    if (! self) {
        return nil;
    }

    _nickname = nickname;

    self.backgroundColor = [UIColor grayColor];

    [self createNameLabel];
    [self createDescriptionLabel];
    [self createDeclineCallButton];
    [self createAcceptCallButton];

    [self installConstraints];

    return self;
}

#pragma mark - View setup
- (void)createNameLabel
{
    self.nameLabel = [UILabel new];
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.text = self.nickname;
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueBoldWithSize:kIncomingNameFontSize];

    [self addSubview:self.nameLabel];

}

- (void)createDescriptionLabel
{
    self.descriptionLabel = [UILabel new];
    self.descriptionLabel.text = NSLocalizedString(@"is calling", @"Calls");
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueBoldWithSize:kIncomingIsCallingFontSize];

    [self addSubview:self.descriptionLabel];
}

- (void)createDeclineCallButton
{
    self.declineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *declineCallImage = [UIImage imageNamed:@"call-decline"];
    [self.declineButton setImage:declineCallImage forState:UIControlStateNormal];
    self.declineButton.tintColor = [UIColor whiteColor];
    self.declineButton.backgroundColor = [[AppContext sharedContext].appearance callRedColor];
    self.declineButton.layer.cornerRadius = kButtonSize / 2.0;
    [self.declineButton addTarget:self action:@selector(tappedDeclineButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.declineButton];
}

- (void)createAcceptCallButton
{
    self.acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *acceptCallimage = [UIImage imageNamed:@"call-phone"];
    [self.acceptButton setImage:acceptCallimage forState:UIControlStateNormal];
    self.acceptButton.tintColor = [UIColor whiteColor];
    self.acceptButton.backgroundColor = [UIColor greenColor];
    self.acceptButton.layer.cornerRadius = kButtonSize / 2.0;
    [self.acceptButton addTarget:self action:@selector(tappedAcceptButton) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.acceptButton];
}

- (void)installConstraints
{
    [self.acceptButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.centerY.equalTo(self);
        make.height.equalTo(kButtonSize);
        make.width.equalTo(kButtonSize);
    }];

    [self.declineButton makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.acceptButton);
        make.centerY.equalTo(self.acceptButton);
        make.right.equalTo(self.acceptButton.left).with.offset(-kIndent);
    }];

    [self.nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left);
        make.height.equalTo(20.0);
        make.bottom.equalTo(self.centerY);
    }];

    [self.descriptionLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.nameLabel);
        make.bottom.equalTo(self.bottom);
        make.top.equalTo(self.centerY);
    }];
}

#pragma mark - Private

- (void)tappedDeclineButton
{
    [self.delegate incomingCallNotificationViewTappedDeclineButton];
}

- (void)tappedAcceptButton
{
    [self.delegate incomingCallNotificationViewTappedAcceptButton];
}

@end
