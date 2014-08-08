//
//  AvatarFactory.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 08.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "AvatarFactory.h"
#import "NSString+Utilities.h"

@implementation AvatarFactory

#pragma mark -  Public

+ (UIImage *)avatarFromString:(NSString *)string side:(CGFloat)side
{
    string = [self firstLettersOfTwoWordsLettersFromString:string];

    UILabel *label = [UILabel new];
    label.backgroundColor = [AppearanceManager bubbleOutgoingColor];
    label.layer.borderColor = [AppearanceManager textMainColor].CGColor;
    label.layer.borderWidth = 1.0;
    label.layer.masksToBounds = YES;
    label.textColor = [AppearanceManager textMainColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = string;

    CGFloat fontSize = 51;
    CGSize size;

    do {
        fontSize--;

        // PL - placeholder in case if avatar text is nil
        NSString *str = string ?: @"PL";

        size = [str stringSizeWithFont:[AppearanceManager fontHelveticaNeueLightWithSize:fontSize]];

    } while (MAX(size.width, size.height) > side);

    CGRect frame = CGRectZero;
    frame.size.width = frame.size.height = side;

    label.font = [AppearanceManager fontHelveticaNeueLightWithSize:fontSize - 15];
    label.layer.cornerRadius = frame.size.width / 2;
    label.frame = frame;

    return [self imageWithView:label];
}

#pragma mark -  Private

+ (NSString *)firstLettersOfTwoWordsLettersFromString:(NSString *)string
{
    NSArray *array = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    NSString *result = nil;

    for (NSUInteger index = 0; index < array.count; index++) {
        NSString *word = array[index];

        if (! word.length) {
            continue;
        }

        NSString *firstLetter = [word substringToIndex:1];

        if (result.length == 2) {
            break;
        }
        else if (result.length == 1) {
            result = [result stringByAppendingString:firstLetter];
        }
        else {
            result = firstLetter;
        }
    }

    return [result uppercaseString];
}

+ (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}

@end
