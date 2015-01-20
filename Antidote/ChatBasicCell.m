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
#import "NSString+Utilities.h"

@interface ChatBasicCell()

@end

@implementation ChatBasicCell

#pragma mark -  Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createChatBasicCellSubviews];
    }
    return self;
}

#pragma mark -  Public

- (void)redraw
{
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

- (CGFloat)startingOriginY
{
    return CGRectGetMaxY(self.fullDateLabel.frame);
}

+ (CGFloat)heightWithFullDateString:(NSString *)fullDateString
{
    if (! fullDateString) {
        return 0.0;
    }

    return [fullDateString stringSizeWithFont:[self fullDateLabelFont]].height;
}

+ (UIFont *)fullDateLabelFont
{
    return [AppearanceManager fontHelveticaNeueWithSize:12.0];
}

#pragma mark -  Private

- (void)createChatBasicCellSubviews
{
    self.backgroundColor = [UIColor clearColor];
    
    self.fullDateLabel = [self.contentView addLabelWithTextColor:[UIColor uColorOpaqueWithWhite:182]
                                                     bgColor:[UIColor clearColor]];
    self.fullDateLabel.font = [[self class] fullDateLabelFont];

    self.hiddenDateLabel = [self.contentView addLabelWithTextColor:[UIColor uColorOpaqueWithWhite:182]
                                                     bgColor:[UIColor clearColor]];
    self.hiddenDateLabel.font = [AppearanceManager fontHelveticaNeueWithSize:12.0];
}

@end
