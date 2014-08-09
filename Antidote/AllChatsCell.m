//
//  AllChatsCell.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "AllChatsCell.h"
#import "UIColor+Utilities.h"

@interface AllChatsCell()

@property (strong, nonatomic) StatusCircleView *statusView;

@end

@implementation AllChatsCell

#pragma mark -  Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];

    if (self) {
        self.textLabel.font = [AppearanceManager fontHelveticaNeueWithSize:20];
        self.detailTextLabel.numberOfLines = 2;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        CGRect frame = self.imageView.frame;
        frame.size.width = frame.size.height = 55.0;
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

- (void)setMessage:(NSString *)message andDate:(NSString *)date
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:
        [NSString stringWithFormat:@"%@\n%@", date ?: @"", message ?: @""]];

    [text setAttributes:@{
        NSForegroundColorAttributeName : [UIColor uColorOpaqueWithWhite:160],
    } range:NSMakeRange(0, date.length)];

    [text setAttributes:@{
        NSForegroundColorAttributeName : [UIColor uColorOpaqueWithWhite:40],
    } range:NSMakeRange(date.length, text.length - date.length)];

    self.detailTextLabel.attributedText = text;
}

+ (CGFloat)height
{
    return 70.0;
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

#pragma mark -  Private

- (void)createStatusView
{
    self.statusView = [StatusCircleView new];
    self.statusView.showWhiteBorder = YES;

    [self.contentView addSubview:self.statusView];
}

- (void)adjustSubviews
{
    CGRect frame = CGRectZero;

    {
        frame = self.statusView.frame;
        frame.origin.x = CGRectGetMaxX(self.imageView.frame) - frame.size.width;
        frame.origin.y = CGRectGetMaxY(self.imageView.frame) - frame.size.height - 2.0;

        self.statusView.frame = frame;
    }
}


@end
