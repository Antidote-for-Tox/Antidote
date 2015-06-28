//
//  AvatarsManager.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 26.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <BlocksKit/NSArray+BlocksKit.h>

#import "AvatarsManager.h"
#import "AppearanceManager.h"
#import "NSString+Utilities.h"

static const NSUInteger kNumberOfLettersInAvatar = 2;

@interface AvatarsManager ()

@property (strong, nonatomic) NSCache *cache;

@end

@implementation AvatarsManager

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    self.cache = [NSCache new];

    return self;
}

#pragma mark -  Public

- (UIImage *)avatarFromString:(NSString *)string diameter:(CGFloat)diameter
{
    NSString *key = [self keyFromString:string diameter:diameter];
    UIImage *avatar = [self.cache objectForKey:key];

    if (avatar) {
        return avatar;
    }

    avatar = [self createAvatarFromString:string diameter:diameter];
    [self.cache setObject:avatar forKey:key];

    return avatar;
}

#pragma mark -  Private

- (NSString *)keyFromString:(NSString *)string diameter:(CGFloat)diameter
{
    return [NSString stringWithFormat:@"%@-%f", string, diameter];
}

- (UIImage *)createAvatarFromString:(NSString *)string diameter:(CGFloat)diameter
{
    string = [self avatarsStringFromString:string];

    UILabel *label = [UILabel new];
    label.backgroundColor = [[AppContext sharedContext].appearance bubbleOutgoingColor];
    label.layer.borderColor = [[AppContext sharedContext].appearance textMainColor].CGColor;
    label.layer.borderWidth = 1.0;
    label.layer.masksToBounds = YES;
    label.textColor = [[AppContext sharedContext].appearance textMainColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = string;

    CGFloat fontSize = 51;
    CGSize size;

    do {
        fontSize--;

        // PL - placeholder in case if avatar text is nil
        NSString *str = string ?: @"PL";

        size = [str stringSizeWithFont:[[AppContext sharedContext].appearance fontHelveticaNeueLightWithSize:fontSize]];

    }
    while (MAX(size.width, size.height) > diameter);

    CGRect frame = CGRectZero;
    frame.size.width = frame.size.height = diameter;

    label.font = [[AppContext sharedContext].appearance fontHelveticaNeueLightWithSize:(int) (fontSize * 0.6)];
    label.layer.cornerRadius = frame.size.width / 2;
    label.frame = frame;

    return [self imageWithView:label];
}

- (NSString *)avatarsStringFromString:(NSString *)string
{
    if (! string.length) {
        return @"";
    }

    NSArray *words = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *result = @"";

    if (words.count > 1) {
        result = [[words bk_map:^NSString *(NSString *word) {
            return (word.length <= 1) ? word : [word substringToIndex:1];
        }] componentsJoinedByString:@""];
    }
    else {
        result = [words firstObject];
    }

    result = (result.length <= kNumberOfLettersInAvatar) ? result : [result substringToIndex:kNumberOfLettersInAvatar];

    return [result uppercaseString];
}

- (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}

@end
