//
//  ChatTypingCell.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 12.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ChatTypingCell.h"
#import "JSQMessagesBubbleImageFactory.h"

static const CGFloat kCellWhitespaceTop = 3.0;
static const UIEdgeInsets kBubbleInsets = { 16.0, 15.0, 16.0, 10.0 };

@interface ChatTypingCell()

@property (strong, nonatomic) UIImageView *bubbleImageView;
@property (strong, nonatomic) UIImageView *dotsImageView;

@end

@implementation ChatTypingCell

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
    CGRect frame = self.dotsImageView.frame;
    frame.origin.x = 30.0;
    frame.origin.y = kCellWhitespaceTop + kBubbleInsets.top;
    self.dotsImageView.frame = frame;

    frame = self.dotsImageView.frame;
    frame.origin.x -= kBubbleInsets.left;
    frame.origin.y -= kBubbleInsets.top;
    frame.size.width += kBubbleInsets.left + kBubbleInsets.right;
    frame.size.height += kBubbleInsets.top + kBubbleInsets.bottom;
    self.bubbleImageView.frame = frame;
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (CGFloat)height
{
    return 50.0;
}

#pragma mark -  Private

- (void)createSubviews
{
    UIColor *color = [AppearanceManager bubbleIncomingColor];
    self.bubbleImageView = [JSQMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:color];
    [self.contentView addSubview:self.bubbleImageView];

    UIImage *image = [UIImage imageNamed:@"typing"];
    self.dotsImageView = [[UIImageView alloc] initWithImage:image];
    [self.contentView addSubview:self.dotsImageView];
}

@end
