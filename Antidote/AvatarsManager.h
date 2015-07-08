//
//  AvatarsManager.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 26.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AvatarsManager : NSObject

/**
 * Returns round avatar from string with a given diameter. Search in cache for avatar first,
 * if not found creates it.
 *
 * @param string String to create avatar from
 * @param diameter Diameter of circle with avatar
 *
 * @return Avatar from given string with given size.
 */
- (UIImage *)avatarFromString:(NSString *)string diameter:(CGFloat)diameter;

/**
 * Returns round avatar from string with a given diameter. Search in cache for avatar first,
 * if not found creates it.
 *
 * @param string String to create avatar from
 * @param diameter Diameter of circle with avatar
 * @param textColor Color of the text and C
 * @param backgroundColor Color of the background.
 *
 * @return Avatar from given string with given size.
 */
- (UIImage *)avatarFromString:(NSString *)string
                     diameter:(CGFloat)diameter
                    textColor:(UIColor *)textColor
              backgroundColor:(UIColor *)backgroundColor;

@end
