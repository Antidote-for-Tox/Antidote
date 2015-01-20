//
//  ChatBasicMessageCell.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 07.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ChatBasicCell.h"

static const CGFloat kChatCellMaxWidthCoefficient = 0.75;
static const CGFloat kChatCellBubleLeftRightOffset = 20.0f;

@interface ChatBasicMessageCell : ChatBasicCell

@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) NSString *message;

+ (UIFont *)messageLabelFont;

@end
