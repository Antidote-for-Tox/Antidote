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
@property (strong, nonatomic) UIButton *checkboxButton;

@end

@implementation FriendRequestsCell

#pragma mark -  Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        [self createTitleView];
        [self createSubtitleView];
        [self createCheckboxButton];
    }

    return self;
}

#pragma mark -  Actions

- (void)checkboxButtonPressed
{
    [self.delegate friendRequestCellAddButtonPressed:self];
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

#pragma mark -  Private

- (void)createTitleView
{
    self.titleLabel = [self.contentView addLabelWithTextColor:[UIColor blackColor] bgColor:[UIColor clearColor]];
}

- (void)createSubtitleView
{
    self.subtitleLabel = [self.contentView addLabelWithTextColor:[UIColor grayColor] bgColor:[UIColor clearColor]];
}

- (void)createCheckboxButton
{
    self.checkboxButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.checkboxButton setTitle:NSLocalizedString(@"Add", @"Friend requests") forState:UIControlStateNormal];
    [self.checkboxButton addTarget:self
                           action:@selector(checkboxButtonPressed)
                 forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.checkboxButton];
}

- (void)adjustSubviews
{
    CGRect frame = CGRectZero;

    {
        frame = CGRectZero;
        frame.size.width = frame.size.height = 40.0;
        frame.origin.x = 5.0;
        frame.origin.y = (self.bounds.size.height - frame.size.height) / 2;
        self.checkboxButton.frame = frame;
    }

    {
        frame = CGRectZero;
        frame.size = [self.titleLabel.text stringSizeWithFont:self.titleLabel.font];
        frame.origin.x = CGRectGetMaxX(self.checkboxButton.frame) + 5.0;
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
