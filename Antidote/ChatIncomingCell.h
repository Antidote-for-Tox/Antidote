//
//  ChatIncomingCell.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ChatBasicMessageCell.h"

@interface ChatIncomingCell : ChatBasicMessageCell

+ (CGFloat)heightWithMessage:(NSString *)message fullDateString:(NSString *)fullDateString;

@end
