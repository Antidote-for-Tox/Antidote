//
//  ChatBasicCell.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 06.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatBasicCell : UITableViewCell

@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UILabel *dateLabel;

@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *dateString;

- (void)redraw;

+ (NSString *)reuseIdentifier;
+ (CGFloat)heightWithMessage:(NSString *)message;
+ (UIFont *)messageLabelFont;

@end
