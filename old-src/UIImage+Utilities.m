//
//  UIImage+Utilities.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 02.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "UIImage+Utilities.h"

@implementation UIImage (Utilities)

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    if (! color) {
        return nil;
    }

    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
