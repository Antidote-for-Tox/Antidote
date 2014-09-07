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
@property (strong, nonatomic) UILabel *fullDateLabel;
@property (strong, nonatomic) UILabel *hiddenDateLabel;

@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *fullDateString;
@property (strong, nonatomic) NSString *hiddenDateString;

- (void)redraw;

+ (CGFloat)heightWithMessage:(NSString *)message fullDateString:(NSString *)fullDateString;
+ (UIFont *)messageLabelFont;
+ (UIFont *)fullDateLabelFont;

@end
