//
//  ChatOutgoingCell.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 06.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ChatBasicMessageCell.h"

@interface ChatOutgoingCell : ChatBasicMessageCell

@property (assign, nonatomic) BOOL isDelivered;

+ (CGFloat)heightWithMessage:(NSString *)message fullDateString:(NSString *)fullDateString;

@end
