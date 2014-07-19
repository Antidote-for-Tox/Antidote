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

@end
