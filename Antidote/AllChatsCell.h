//
//  AllChatsCell.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StatusCircleView.h"

@interface AllChatsCell : UITableViewCell

@property (assign, nonatomic) StatusCircleStatus status;

- (void)setMessage:(NSString *)message andDate:(NSString *)date;

+ (CGFloat)height;

@end
