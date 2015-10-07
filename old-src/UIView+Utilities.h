//
//  UIView+Utilities.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CopyLabel.h"

@interface UIView (Utilities)

- (UILabel *)addLabelWithTextColor:(UIColor *)textColor bgColor:(UIColor *)bgColor;
- (CopyLabel *)addCopyLabelWithTextColor:(UIColor *)textColor bgColor:(UIColor *)bgColor;

@end
