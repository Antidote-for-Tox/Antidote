//
//  ChatBasicCell.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 06.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ChatBasicCell.h"
#import "UIView+Utilities.h"
#import "UIColor+Utilities.h"

@interface ChatBasicCell()

@end

@implementation ChatBasicCell

#pragma mark -  Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createBasicSubviews];
    }
    return self;
}

#pragma mark -  Public

- (void)redraw
{
    self.messageLabel.text = self.message;

    self.dateLabel.text = self.dateString;

    [self.dateLabel sizeToFit];
    CGRect frame = self.dateLabel.frame;
    frame.origin.x = self.bounds.size.width;
    frame.origin.y = (self.bounds.size.height - frame.size.height) / 2;
    self.dateLabel.frame = frame;
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (CGFloat)heightWithMessage:(NSString *)message
{
    return 0.0;
}

+ (UIFont *)messageLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue" size:16];
}

#pragma mark -  Private

- (void)createBasicSubviews
{
    self.messageLabel = [self.contentView addLabelWithTextColor:[UIColor blackColor]
                                                        bgColor:[UIColor clearColor]];
    self.messageLabel.font = [[self class] messageLabelFont];
    self.messageLabel.numberOfLines = 0;

    self.dateLabel = [self.contentView addLabelWithTextColor:[UIColor uColorOpaqueWithWhite:182]
                                                     bgColor:[UIColor clearColor]];
    self.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
}

@end
