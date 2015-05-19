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
        [self adjustSubviews];

        self.textLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:20];
        self.detailTextLabel.numberOfLines = 2;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2;
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

#pragma mark -  Private

- (void)createStatusView
{
    self.statusView = [StatusCircleView new];
    self.statusView.showWhiteBorder = YES;

    [self.contentView addSubview:self.statusView];
}

- (void)adjustSubviews
{
    CGRect frame = self.imageView.frame;
    frame.size.width = frame.size.height = 55.0;
    frame.origin.x = 10.0;
    frame.origin.y = (self.contentView.frame.size.height - frame.size.height) / 2;
    self.imageView.frame = frame;

    frame = self.textLabel.frame;
    frame.origin.x = CGRectGetMaxX(self.imageView.frame) + 10.0;
    frame.size.width = self.frame.size.width - frame.origin.x - 30.0;
    self.textLabel.frame = frame;

    frame = self.detailTextLabel.frame;
    frame.origin.x = self.textLabel.frame.origin.x;
    frame.size.width = self.textLabel.frame.size.width;
    self.detailTextLabel.frame = frame;

    frame = self.statusView.frame;
    frame.origin.x = CGRectGetMaxX(self.imageView.frame) - frame.size.width;
    frame.origin.y = CGRectGetMaxY(self.imageView.frame) - frame.size.height - 2.0;
    self.statusView.frame = frame;
}


@end
