//
//  UIColor+Utilities.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "UIColor+Utilities.h"

@implementation UIColor (Utilities)

+ (UIColor *)uColorOpaqueWithWhite:(unsigned char)white
{
    return [self uColorWithWhite:white alpha:1.0];
}

+ (UIColor *)uColorWithWhite:(unsigned char)white alpha:(CGFloat)alpha
{
    return [self uColorWithRed:white green:white blue:white alpha:alpha];
}

+ (UIColor *)uColorOpaqueWithRed:(unsigned char)red
                           green:(unsigned char)green
                            blue:(unsigned char)blue
{
    return [self uColorWithRed:red green:green blue:blue alpha:1.0];
}

+ (UIColor *)uColorWithRed:(unsigned char)red
                     green:(unsigned char)green
                      blue:(unsigned char)blue
                     alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:red / 255.0
                           green:green / 255.0
                            blue:blue / 255.0
                           alpha:alpha];
}

@end
