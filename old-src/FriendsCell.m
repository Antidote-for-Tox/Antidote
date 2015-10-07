//
//  FriendsCell.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "FriendsCell.h"
#import "NSString+Utilities.h"
#import "UIColor+Utilities.h"
#import "AppearanceManager.h"

const CGFloat kFriendsCellAvatarSize = 30.0;

static const CGFloat kAvatarLeftOffset = 10.0;
static const CGFloat kAvatarRightOffset = 16.0;
static const CGFloat kVerticalOffset = 3.0;

static const CGFloat kStatusViewSize = 8.0;
static const CGFloat kStatusViewLeftOffset = 8.0;

@interface FriendsCell ()

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *statusMessageLabel;
@property (strong, nonatomic) StatusCircleView *statusView;

@end

@implementation FriendsCell

#pragma mark -  Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];

    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.separatorInset = UIEdgeInsetsMake(0.0, kAvatarLeftOffset + kFriendsCellAvatarSize + kAvatarRightOffset, 0.0, 0.0);

        [self createViews];

        [self installConstraints];
    }

    return self;
}

#pragma mark -  Properties

- (void)setAvatar:(UIImage *)avatar
{
    self.avatarImageView.image = avatar;
}

- (UIImage *)avatar
{
    return self.avatarImageView.image;
}

- (void)setName:(NSString *)name
{
    self.nameLabel.text = name;
}

- (NSString *)name
{
    return self.nameLabel.text;
}

- (void)setStatusMessage:(NSString *)statusMessage
{
    self.statusMessageLabel.text = statusMessage;
}

- (NSString *)statusMessage
{
    return self.statusMessageLabel.text;
}

- (void)setShowStatusView:(BOOL)show
{
    self.statusView.hidden = ! show;
}

- (BOOL)showStatusView
{
    return self.statusView.hidden;
}

- (void)setStatus:(StatusCircleStatus)status
{
    self.statusView.status = status;

    [self.statusView redraw];
}

- (StatusCircleStatus)status
{
    return self.statusView.status;
}

#pragma mark -  Private

- (void)createViews
{
    self.avatarImageView = [UIImageView new];
    self.avatarImageView.backgroundColor = [UIColor clearColor];
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImageView.layer.cornerRadius = kFriendsCellAvatarSize / 2;
    self.avatarImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.avatarImageView];

    self.nameLabel = [UILabel new];
    self.nameLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:18];
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.nameLabel];

    self.statusMessageLabel = [UILabel new];
    self.statusMessageLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:12];
    self.statusMessageLabel.textColor = [UIColor uColorOpaqueWithWhite:140];
    self.statusMessageLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.statusMessageLabel];

    self.statusView = [StatusCircleView new];
    self.statusView.side = kStatusViewSize;
    [self.contentView addSubview:self.statusView];
}

- (void)installConstraints
{
    [self.avatarImageView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(kAvatarLeftOffset);
        make.centerY.equalTo(self.contentView);
        make.size.equalTo(kFriendsCellAvatarSize);
    }];

    [self.nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarImageView.right).offset(kAvatarRightOffset);
        make.top.equalTo(self.contentView).offset(kVerticalOffset);
    }];

    [self.statusMessageLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.right.lessThanOrEqualTo(self.contentView);
        make.top.equalTo(self.nameLabel.bottom);
        make.bottom.equalTo(self.contentView).offset(-kVerticalOffset);
    }];

    [self.statusView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.right).offset(kStatusViewLeftOffset);
        make.right.lessThanOrEqualTo(self.contentView);
        make.centerY.equalTo(self.nameLabel);
        make.size.equalTo(kStatusViewSize);
    }];
}

@end
