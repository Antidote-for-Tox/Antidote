//
//  FriendRequestsCell.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "FriendRequestsCell.h"
#import "NSString+Utilities.h"
#import "UIView+Utilities.h"

@interface FriendRequestsCell()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;

@end

@implementation FriendRequestsCell

#pragma mark -  Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        [self createTitleView];
        [self createSubtitleView];
    }

    return self;
}

#pragma mark -  Public

- (void)redraw
{
    self.titleLabel.text = self.title;
    self.subtitleLabel.text = self.subtitle;

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

- (void)createTitleView
{
    self.titleLabel = [self.contentView addLabelWithTextColor:[UIColor blackColor] bgColor:[UIColor clearColor]];
}

- (void)createSubtitleView
{
    self.subtitleLabel = [self.contentView addLabelWithTextColor:[UIColor grayColor] bgColor:[UIColor clearColor]];
}

- (void)adjustSubviews
{
    CGRect frame = CGRectZero;

    {
        frame = CGRectZero;
        frame.size = [self.titleLabel.text stringSizeWithFont:self.titleLabel.font];
        frame.origin.x = 50.0;
        frame.origin.y = 5.0;
        frame.size.width = self.bounds.size.width - frame.origin.x;

        self.titleLabel.frame = frame;
    }

    {
        frame = CGRectZero;
        frame.size = [self.subtitleLabel.text stringSizeWithFont:self.subtitleLabel.font];
        frame.origin.x = CGRectGetMinX(self.titleLabel.frame);
        frame.origin.y = CGRectGetMaxY(self.titleLabel.frame) + 1.0;
        frame.size.width = self.bounds.size.width - frame.origin.x;

        self.subtitleLabel.frame = frame;
    }

}

@end
