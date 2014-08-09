//
//  FriendsCell.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "FriendsCell.h"
#import "NSString+Utilities.h"
#import "UIColor+Utilities.h"

@interface FriendsCell()

@property (strong, nonatomic) StatusCircleView *statusView;

@end

@implementation FriendsCell

#pragma mark -  Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];

    if (self) {
        self.textLabel.font = [AppearanceManager fontHelveticaNeueWithSize:18];
        self.detailTextLabel.textColor = [UIColor uColorOpaqueWithWhite:140];
        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

        CGRect frame = self.imageView.frame;
        frame.size.width = frame.size.height = 30.0;
        self.imageView.frame = frame;

        self.imageView.layer.cornerRadius = frame.size.width / 2;
        self.imageView.layer.masksToBounds = YES;

        [self createStatusView];
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

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self adjustSubviews];
}

#pragma mark -  Properties

- (void)setStatus:(StatusCircleStatus)status
{
    self.statusView.status = status;

    [self.statusView redraw];
}

- (StatusCircleStatus)status
{
    return self.statusView.status;
}

#pragma mark -  Public

+ (CGFloat)height
{
    return 44.0;
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

#pragma mark -  Private

- (void)createStatusView
{
    self.statusView = [StatusCircleView new];
    self.statusView.side = 8.0;

    [self.contentView addSubview:self.statusView];
}

- (void)adjustSubviews
{
    CGRect frame = CGRectZero;

    {
        CGSize size = [self.textLabel.text stringSizeWithFont:self.textLabel.font];

        frame = self.statusView.frame;
        frame.origin.x = CGRectGetMinX(self.textLabel.frame) + size.width + 8.0;
        frame.origin.y = (CGRectGetMaxY(self.textLabel.frame) - frame.size.height) / 2 + 2.0;

        self.statusView.frame = frame;
    }
}

@end
