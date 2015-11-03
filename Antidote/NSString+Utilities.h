//
//  NSString+Utilities.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utilities)

- (CGSize)stringSizeWithFont:(UIFont *)font;
- (CGSize)stringSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

- (NSString *)substringToByteLength:(NSUInteger)length usingEncoding:(NSStringEncoding)encoding;

/**
 * Takes a given time interval and provides the time in mm:ss.
 * For example 83 seconds -> @"01:23".
 * @param interval the seconds to convert.
 * @return String representation of the seconds
 */
+ (NSString *)stringFromTimeInterval:(NSTimeInterval)interval;

@end
