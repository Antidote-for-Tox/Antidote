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

static const CGFloat kMaxMessageWidth = 240.0;

static const CGFloat kCellWhitespaceTop = 3.0;
static const CGFloat kCellWhitespaceBottom = 3.0;
static const UIEdgeInsets kBubbleInsets = { 10.0, 10.0, 10.0, 15.0 };

@interface ChatOutgoingCell()

@property (strong, nonatomic) UIImageView *bubbleImageView;

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
    frame.origin.y = kCellWhitespaceTop + kBubbleInsets.top;
    self.messageLabel.frame = frame;

    frame = self.messageLabel.frame;
    frame.origin.x -= kBubbleInsets.left;
    frame.origin.y -= kBubbleInsets.top;
    frame.size.width += kBubbleInsets.left + kBubbleInsets.right;
    frame.size.height += kBubbleInsets.top + kBubbleInsets.bottom;
    self.bubbleImageView.frame = frame;
}

+ (CGFloat)heightWithMessage:(NSString *)message
{
    CGSize size = [message stringSizeWithFont:[self messageLabelFont]
                            constrainedToSize:CGSizeMake(kMaxMessageWidth, CGFLOAT_MAX)];

    return kCellWhitespaceTop + kBubbleInsets.top + size.height + kBubbleInsets.bottom + kCellWhitespaceBottom;
}

#pragma mark -  Private

- (void)createSubviews
{
    UIColor *color = [AppearanceManager bubbleOutgoingColor];
    self.bubbleImageView = [JSQMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:color];
    [self.contentView addSubview:self.bubbleImageView];

    [self.contentView sendSubviewToBack:self.bubbleImageView];
}

@end
