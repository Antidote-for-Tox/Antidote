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

const CGFloat kFriendsCellImageViewSize = 30.0;

static const CGFloat kImageViewLeftOffset = 10.0;
static const CGFloat kStatusViewSize = 8.0;
static const CGFloat kStatusViewLeftOffset = 8.0;
static const CGFloat kStatusViewMinimumRightOffset = -30.0;

@interface FriendsCell ()

@property (strong, nonatomic) StatusCircleView *statusView;

@end

@implementation FriendsCell

#pragma mark -  Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];

    if (self) {
        self.textLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:18];
        self.detailTextLabel.textColor = [UIColor uColorOpaqueWithWhite:140];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.cornerRadius = kFriendsCellImageViewSize / 2;
        self.imageView.layer.masksToBounds = YES;

        [self createStatusView];

        [self installConstraints];
    }

    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];

    // fixing background colors in highlighted state
    [self.statusView redraw];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // fixing background colors in selected state
    [self.statusView redraw];
}

#pragma mark -  Properties

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

- (void)createStatusView
{
    self.statusView = [StatusCircleView new];
    self.statusView.side = kStatusViewSize;
    [self.contentView addSubview:self.statusView];
}

- (void)installConstraints
{
    [self.imageView makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(kFriendsCellImageViewSize);
        make.centerY.equalTo(self);
        make.left.equalTo(kImageViewLeftOffset);
    }];

    [self.statusView makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(kStatusViewSize);
        make.left.equalTo(self.textLabel.right).offset(kStatusViewLeftOffset).priorityLow();
        make.right.lessThanOrEqualTo(self.right).offset(kStatusViewMinimumRightOffset);
        make.centerY.equalTo(self.textLabel);
    }];
}

@end
