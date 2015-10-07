//
//  UIView+Utilities.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "UIView+Utilities.h"

@implementation UIView (Utilities)

#pragma mark -  Public

- (UILabel *)addLabelWithTextColor:(UIColor *)textColor bgColor:(UIColor *)bgColor
{
    return [self configureAndAddLabel:[UILabel new] withTextColor:textColor bgColor:bgColor];
}

- (CopyLabel *)addCopyLabelWithTextColor:(UIColor *)textColor bgColor:(UIColor *)bgColor
{
    return (CopyLabel *) [self configureAndAddLabel:[CopyLabel new] withTextColor:textColor bgColor:bgColor];
}

#pragma mark -  Private

- (UILabel *)configureAndAddLabel:(UILabel *)label withTextColor:(UIColor *)textColor bgColor:(UIColor *)bgColor
{
    label.textColor = textColor;
    label.backgroundColor = bgColor;
    [self addSubview:label];

    return label;
}

@end
