//
//  ChatIncomingCell.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ChatIncomingCell.h"
#import "JSQMessagesBubbleImageFactory.h"
#import "NSString+Utilities.h"

static const CGFloat kCellWhitespaceTop = 3.0;
static const CGFloat kCellWhitespaceBottom = 3.0;
static const UIEdgeInsets kBubbleInsets = { 10.0, 15.0, 10.0, 10.0 };

@interface ChatIncomingCell()

@property (strong, nonatomic) UIImageView *bubbleImageView;

@end

@implementation ChatIncomingCell

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

    CGFloat maxMessageWidth = floorf(self.bounds.size.width * kChatCellMaxWidthCoefficient);
    
    CGRect frame = CGRectZero;
    frame.size = [self.message stringSizeWithFont:self.messageLabel.font
                                constrainedToSize:CGSizeMake(maxMessageWidth, CGFLOAT_MAX)];
    frame.origin.x = kChatCellBubleLeftRightOffset;
    frame.origin.y = [self startingOriginY] + kCellWhitespaceTop + kBubbleInsets.top;
    self.messageLabel.frame = frame;

    frame = self.messageLabel.frame;
    frame.origin.x -= kBubbleInsets.left;
    frame.origin.y -= kBubbleInsets.top;
    frame.size.width += kBubbleInsets.left + kBubbleInsets.right;
    frame.size.height += kBubbleInsets.top + kBubbleInsets.bottom;
    self.bubbleImageView.frame = frame;
}

+ (CGFloat)heightWithMessage:(NSString *)message fullDateString:(NSString *)fullDateString
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat maxMessageWidth = floorf(width * kChatCellMaxWidthCoefficient);

    CGSize messageSize = [message stringSizeWithFont:[self messageLabelFont]
                                   constrainedToSize:CGSizeMake(maxMessageWidth, CGFLOAT_MAX)];

    return [super heightWithFullDateString:fullDateString] +
        kCellWhitespaceTop + kBubbleInsets.top + messageSize.height + kBubbleInsets.bottom + kCellWhitespaceBottom;
}

#pragma mark -  Private

- (void)createSubviews
{
    UIColor *color = [AppearanceManager bubbleIncomingColor];
    self.bubbleImageView = [JSQMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:color];
    self.bubbleImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.bubbleImageView];

    [self.contentView sendSubviewToBack:self.bubbleImageView];
}

@end
