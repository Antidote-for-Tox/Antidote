//
//  ChatBasicMessageCell.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 07.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ChatBasicMessageCell.h"
#import "UIView+Utilities.h"

@implementation ChatBasicMessageCell

#pragma mark -  Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        [self createChatBasicMessageCellSubviews];
    }

    return self;
}

#pragma mark -  Public

- (void)redraw
{
    [super redraw];

    self.messageLabel.text = self.message;

}

+ (UIFont *)messageLabelFont
{
    return [AppearanceManager fontHelveticaNeueWithSize:16.0];
}

#pragma mark -  Private

- (void)createChatBasicMessageCellSubviews
{
    self.messageLabel = [self.contentView addLabelWithTextColor:[UIColor blackColor]
                                                        bgColor:[UIColor clearColor]];
    self.messageLabel.font = [[self class] messageLabelFont];
    self.messageLabel.numberOfLines = 0;
}

@end
