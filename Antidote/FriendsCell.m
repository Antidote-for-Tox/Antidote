//
//  FriendsCell.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "FriendsCell.h"
#import "NSString+Utilities.h"
#import "UIView+Utilities.h"

@interface FriendsCell()

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) StatusCircleView *statusView;

@end

@implementation FriendsCell

#pragma mark -  Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        [self createAvatarImageView];
        [self createTitleView];
        [self createSubtitleView];
        [self createStatusView];
    }

    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    // fixing background colors in highlighted state

    UIColor *avatar = self.avatarImageView.backgroundColor;
    UIColor *status = self.statusView.backgroundColor;

    [super setHighlighted:highlighted animated:animated];

    self.avatarImageView.backgroundColor = avatar;
    self.statusView.backgroundColor = status;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    // fixing background colors in selected state

    UIColor *avatar = self.avatarImageView.backgroundColor;
    UIColor *status = self.statusView.backgroundColor;

    [super setSelected:selected animated:animated];

    self.avatarImageView.backgroundColor = avatar;
    self.statusView.backgroundColor = status;
}

#pragma mark -  Public

- (void)redraw
{
    self.avatarImageView.image = self.avatarImage;
    self.titleLabel.text = self.title;
    self.subtitleLabel.text = self.subtitle;

    self.statusView.status = self.status;
    [self.statusView redraw];

    [self adjustSubviews];
}

+ (CGFloat)height
{
    return 50.0;
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

#pragma mark -  Private

- (void)createAvatarImageView
{
    CGRect frame = CGRectZero;
    frame.size.width = frame.size.height = 40.0;

    self.avatarImageView = [[UIImageView alloc] initWithFrame:frame];
    self.avatarImageView.backgroundColor = [UIColor grayColor];
    self.avatarImageView.layer.cornerRadius = 3.0;

    [self.contentView addSubview:self.avatarImageView];
}

- (void)createTitleView
{
    self.titleLabel = [self.contentView addLabelWithTextColor:[UIColor blackColor] bgColor:[UIColor clearColor]];
}

- (void)createSubtitleView
{
    self.subtitleLabel = [self.contentView addLabelWithTextColor:[UIColor grayColor] bgColor:[UIColor clearColor]];
}

- (void)createStatusView
{
    self.statusView = [StatusCircleView new];
    [self.contentView addSubview:self.statusView];
}

- (void)adjustSubviews
{
    CGRect frame = CGRectZero;

    {
        frame = self.avatarImageView.frame;
        frame.origin.x = 10.0;
        frame.origin.y = (self.bounds.size.height - frame.size.height) / 2;
        self.avatarImageView.frame = frame;
    }

    {
        frame = CGRectZero;
        frame.size = [self.titleLabel.text stringSizeWithFont:self.titleLabel.font];
        frame.size.width = MIN(230.0, frame.size.width);
        frame.origin.x = CGRectGetMaxX(self.avatarImageView.frame) + 10.0;
        frame.origin.y = self.avatarImageView.frame.origin.y;

        self.titleLabel.frame = frame;
    }

    {
        frame = CGRectZero;
        frame.size = [self.subtitleLabel.text stringSizeWithFont:self.subtitleLabel.font];
        frame.size.width = MIN(230.0, frame.size.width);
        frame.origin.x = CGRectGetMinX(self.titleLabel.frame);
        frame.origin.y = CGRectGetMaxY(self.titleLabel.frame) + 1.0;

        self.subtitleLabel.frame = frame;
    }

    {
        frame = self.statusView.frame;
        frame.origin.x = CGRectGetMaxX(self.titleLabel.frame) + 10.0;
        frame.origin.y = CGRectGetMinY(self.titleLabel.frame) +
            (self.titleLabel.frame.size.height - frame.size.height) / 2;
        self.statusView.frame = frame;
    }
}

@end
