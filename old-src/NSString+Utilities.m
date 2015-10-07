//
//  NSString+Utilities.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

- (CGSize)stringSizeWithFont:(UIFont *)font
{
    return [self stringSizeWithFont:font constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}

- (CGSize)stringSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    CGRect boundingRect = [self boundingRectWithSize:size
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName : font}
                                             context:nil];

    return CGSizeMake(ceil(boundingRect.size.width), ceil(boundingRect.size.height));
}

- (NSString *)substringToByteLength:(NSUInteger)length usingEncoding:(NSStringEncoding)encoding
{
    if (! length) {
        return @"";
    }

    NSString *substring = self;

    while ([substring lengthOfBytesUsingEncoding:encoding] > length) {
        NSUInteger newLength = substring.length - 1;

        if (! newLength) {
            return @"";
        }

        substring = [substring substringToIndex:newLength];
    }

    return substring;
}

@end
