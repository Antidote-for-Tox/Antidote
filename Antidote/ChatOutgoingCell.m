//
//  ChatOutgoingCell.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 06.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ChatOutgoingCell.h"
#import "JSQMessagesBubbleImageFactory.h"
#import "NSString+Utilities.h"
#import "UIColor+Utilities.h"
#import "UIView+Utilities.h"

static const CGFloat kMaxMessageWidth = 240.0;

static const CGFloat kCellWhitespaceTop = 3.0;
static const CGFloat kCellWhitespaceBottom = 3.0;
static const UIEdgeInsets kBubbleInsets = { 10.0, 10.0, 10.0, 15.0 };

@interface ChatOutgoingCell()

@property (strong, nonatomic) UIImageView *bubbleImageView;
@property (strong, nonatomic) UIImageView *checkmarkImageView;

@end

@implementation ChatOutgoingCell

#pragma mark -  Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        [self createSubviews];
    }

    return self;
}

#pragma mark -  Public

- (void)redraw
{
    [super redraw];

    CGRect frame = CGRectZero;
    frame.size = [self.message stringSizeWithFont:self.messageLabel.font
                                constrainedToSize:CGSizeMake(kMaxMessageWidth, CGFLOAT_MAX)];
    frame.origin.x = self.bounds.size.width - frame.size.width - 30.0;
    frame.origin.y = [self startingOriginY] + kCellWhitespaceTop + kBubbleInsets.top;
    self.messageLabel.frame = frame;

    frame = self.messageLabel.frame;
    frame.origin.x -= kBubbleInsets.left;
    frame.origin.y -= kBubbleInsets.top;
    frame.size.width += kBubbleInsets.left + kBubbleInsets.right;
    frame.size.height += kBubbleInsets.top + kBubbleInsets.bottom;
    self.bubbleImageView.frame = frame;

    if (self.isDelivered) {
        self.checkmarkImageView.hidden = NO;

        frame = self.checkmarkImageView.frame;
        frame.origin.x = CGRectGetMinX(self.bubbleImageView.frame) - frame.size.width - 12.0;
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height - 8.0;
        self.checkmarkImageView.frame = frame;
    }
    else {
        self.checkmarkImageView.hidden = YES;
    }
}

+ (CGFloat)heightWithMessage:(NSString *)message fullDateString:(NSString *)fullDateString
{
    CGSize messageSize = [message stringSizeWithFont:[self messageLabelFont]
                            constrainedToSize:CGSizeMake(kMaxMessageWidth, CGFLOAT_MAX)];

    return [super heightWithFullDateString:fullDateString] +
        kCellWhitespaceTop + kBubbleInsets.top + messageSize.height + kBubbleInsets.bottom + kCellWhitespaceBottom;
}

#pragma mark -  Private

- (void)createSubviews
{
    UIColor *color = [AppearanceManager bubbleOutgoingColor];
    self.bubbleImageView = [JSQMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:color];
    [self.contentView addSubview:self.bubbleImageView];

    [self.contentView sendSubviewToBack:self.bubbleImageView];

    UIImage *image = [UIImage imageNamed:@"chat-delivered-checkmark"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    self.checkmarkImageView = [[UIImageView alloc] initWithImage:image];
    self.checkmarkImageView.tintColor = [UIColor uColorOpaqueWithWhite:200];
    [self.contentView addSubview:self.checkmarkImageView];
}

@end
