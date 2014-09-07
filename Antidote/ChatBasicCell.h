//
//  ChatBasicCell.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 06.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatBasicCell : UITableViewCell

@property (strong, nonatomic) UILabel *fullDateLabel;
@property (strong, nonatomic) UILabel *hiddenDateLabel;

@property (strong, nonatomic) NSString *fullDateString;
@property (strong, nonatomic) NSString *hiddenDateString;

- (void)redraw;

// originY from which subclasses should place their views
- (CGFloat)startingOriginY;

+ (CGFloat)heightWithFullDateString:(NSString *)fullDateString;
+ (UIFont *)fullDateLabelFont;

@end
