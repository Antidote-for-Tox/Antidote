//
//  UIColor+Utilities.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utilities)

+ (UIColor *)uColorOpaqueWithWhite:(unsigned char)white;

+ (UIColor *)uColorWithWhite:(unsigned char)white alpha:(CGFloat)alpha;

+ (UIColor *)uColorOpaqueWithRed:(unsigned char)red
                           green:(unsigned char)green
                            blue:(unsigned char)blue;

+ (UIColor *)uColorWithRed:(unsigned char)red
                     green:(unsigned char)green
                      blue:(unsigned char)blue
                     alpha:(CGFloat)alpha;

@end
