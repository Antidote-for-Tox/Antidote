//
//  ChatFileCell.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 14.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ChatFileCell.h"

@interface ChatFileCell()

@property (strong, nonatomic) UIButton *yesButton;
@property (strong, nonatomic) UIButton *noButton;

@end

@implementation ChatFileCell

#pragma mark -  Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        [self createSubviews];
    }

    return self;
}

#pragma mark -  Actions

- (void)yesButtonPressed
{
    [self.delegate chatFileCellButtonPressedYes:self];
}

- (void)noButtonPressed
{
    [self.delegate chatFileCellButtonPressedNo:self];
}

#pragma mark -  Public

- (void)redraw
{
    self.yesButton.hidden = self.noButton.hidden = ! self.showYesNoButtons;

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

- (void)createSubviews
{
    UIImage *yesImage = [UIImage imageNamed:@"checkmark-yes"];
    UIImage *noImage = [UIImage imageNamed:@"checkmark-no"];

    CGRect frame = CGRectZero;
    frame.size = yesImage.size;

    self.yesButton = [[UIButton alloc] initWithFrame:frame];
    [self.yesButton setImage:yesImage forState:UIControlStateNormal];
    [self.yesButton addTarget:self action:@selector(yesButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.yesButton];

    frame.size = noImage.size;

    self.noButton = [[UIButton alloc] initWithFrame:frame];
    [self.noButton setImage:noImage forState:UIControlStateNormal];
    [self.noButton addTarget:self action:@selector(noButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.noButton];
}

- (void)adjustSubviews
{
    CGRect frame = self.noButton.frame;
    frame.origin.x = self.contentView.frame.size.width - frame.size.width;
    frame.origin.y = (self.contentView.frame.size.height - frame.size.height) / 2;
    self.noButton.frame = frame;

    frame = self.yesButton.frame;
    frame.origin.x = CGRectGetMinX(self.noButton.frame) - frame.size.width;
    frame.origin.y = (self.contentView.frame.size.height - frame.size.height) / 2;
    self.yesButton.frame = frame;

    [self.contentView bringSubviewToFront:self.noButton];
    [self.contentView bringSubviewToFront:self.yesButton];
}

@end
