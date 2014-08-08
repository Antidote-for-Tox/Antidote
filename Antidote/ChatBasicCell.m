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

    self.fullDateLabel.text = self.fullDateString;
    [self.fullDateLabel sizeToFit];
    CGRect frame = self.fullDateLabel.frame;
    frame.origin.x = (self.bounds.size.width - frame.size.width) / 2;
    frame.origin.y = 0.0;
    self.fullDateLabel.frame = frame;

    self.hiddenDateLabel.text = self.hiddenDateString;

    [self.hiddenDateLabel sizeToFit];
    frame = self.hiddenDateLabel.frame;
    frame.origin.x = self.bounds.size.width;
    frame.origin.y = (self.bounds.size.height - frame.size.height) / 2;
    self.hiddenDateLabel.frame = frame;
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (CGFloat)heightWithMessage:(NSString *)message fullDateString:(NSString *)fullDateString
{
    return 0.0;
}

+ (UIFont *)messageLabelFont
{
    return [AppearanceManager fontHelveticaNeueWithSize:16.0];
}

+ (UIFont *)fullDateLabelFont
{
    return [AppearanceManager fontHelveticaNeueWithSize:12.0];
}

#pragma mark -  Private

- (void)createBasicSubviews
{
    self.messageLabel = [self.contentView addLabelWithTextColor:[UIColor blackColor]
                                                        bgColor:[UIColor clearColor]];
    self.messageLabel.font = [[self class] messageLabelFont];
    self.messageLabel.numberOfLines = 0;

    self.fullDateLabel = [self.contentView addLabelWithTextColor:[UIColor uColorOpaqueWithWhite:182]
                                                     bgColor:[UIColor clearColor]];
    self.fullDateLabel.font = [[self class] fullDateLabelFont];

    self.hiddenDateLabel = [self.contentView addLabelWithTextColor:[UIColor uColorOpaqueWithWhite:182]
                                                     bgColor:[UIColor clearColor]];
    self.hiddenDateLabel.font = [AppearanceManager fontHelveticaNeueWithSize:12.0];
}

@end
