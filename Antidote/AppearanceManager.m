//
//  AppearanceManager.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 07.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "AppearanceManager.h"
#import "UIColor+Utilities.h"

@interface AppearanceManager ()

@property (assign, nonatomic, readwrite) AppearanceManagerColorscheme colorscheme;

@end

@implementation AppearanceManager

#pragma mark -  Lifecycle

- (instancetype)initWithColorscheme:(AppearanceManagerColorscheme)colorscheme;
{
    self = [super init];

    if (! self) {
        return nil;
    }

    [self setColorscheme:colorscheme];

    return self;
}

#pragma mark -  Public

- (UIFont *)fontHelveticaNeueWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

- (UIFont *)fontHelveticaNeueLightWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
}

- (UIFont *)fontHelveticaNeueBoldWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
}

- (UIColor *)linkYellowColor
{
    return [self bubbleIncomingColorForScheme:self.colorscheme];
}

- (UIColor *)textMainColor
{
    return [self textMainColorForScheme:self.colorscheme];
}

- (UIColor *)lightGrayBackground
{
    return [UIColor uColorOpaqueWithRed:239 green:239 blue:244];
}

- (UIColor *)statusOfflineColor
{
    return [UIColor uColorOpaqueWithWhite:170];
}

- (UIColor *)statusOnlineColor;
{
    switch (self.colorscheme) {
        case AppearanceManagerColorschemeIce:
            return [UIColor uColorOpaqueWithRed:133 green:180 blue:82];
        case __AppearanceManagerColorschemeCount:
            NSAssert(NO, @"We shouldn't be here");
            return nil;
    }
}

- (UIColor *)statusAwayColor;
{
    switch (self.colorscheme) {
        case AppearanceManagerColorschemeIce:
            return [UIColor uColorOpaqueWithRed:222 green:207 blue:78];
        case __AppearanceManagerColorschemeCount:
            NSAssert(NO, @"We shouldn't be here");
            return nil;
    }
}

- (UIColor *)statusBusyColor;
{
    switch (self.colorscheme) {
        case AppearanceManagerColorschemeIce:
            return [UIColor uColorOpaqueWithRed:197 green:98 blue:88];
        case __AppearanceManagerColorschemeCount:
            NSAssert(NO, @"We shouldn't be here");
            return nil;
    }
}

- (UIColor *)bubbleIncomingColor;
{
    return [self bubbleIncomingColorForScheme:self.colorscheme];
}

- (UIColor *)bubbleOutgoingColor
{
    switch (self.colorscheme) {
        case AppearanceManagerColorschemeIce:
            return [UIColor uColorOpaqueWithRed:199 green:225 blue:237];
        case __AppearanceManagerColorschemeCount:
            NSAssert(NO, @"We shouldn't be here");
            return nil;
    }
}

- (UIColor *)unreadChatCellBackground
{
    return [self unreadChatCellBackgroundWithAlpha:1.0];
}

- (UIColor *)unreadChatCellBackgroundWithAlpha:(CGFloat)alpha
{
    switch (self.colorscheme) {
        case AppearanceManagerColorschemeIce:
            return [UIColor uColorWithRed:225 green:237 blue:242 alpha:alpha];
        case __AppearanceManagerColorschemeCount:
            NSAssert(NO, @"We shouldn't be here");
            return nil;
    }
}

- (UIColor *)textMainColorForScheme:(AppearanceManagerColorscheme)scheme
{
    switch (scheme) {
        case AppearanceManagerColorschemeIce:
            return [UIColor uColorOpaqueWithRed:38 green:133 blue:172];
        case __AppearanceManagerColorschemeCount:
            NSAssert(NO, @"We shouldn't be here");
            return nil;
    }
}

- (UIColor *)bubbleIncomingColorForScheme:(AppearanceManagerColorscheme)scheme
{
    switch (scheme) {
        case AppearanceManagerColorschemeIce:
            return [UIColor uColorOpaqueWithRed:255 green:247 blue:229];
        case __AppearanceManagerColorschemeCount:
            NSAssert(NO, @"We shouldn't be here");
            return nil;
    }
}

- (UIColor *)loginBackgroundColor
{
    return [self textMainColor];
}

- (UIColor *)loginButtonColor
{
    return [UIColor uColorWithRed:13 green:103 blue:140 alpha:1.0];
}

- (UIColor *)loginNavigationBarColor
{
    // https://developer.apple.com/library/ios/qa/qa1808/_index.html
    CGFloat colorDelta = 0.08;

    CGFloat red, green, blue, alpha;

    [[self loginButtonColor] getRed:&red green:&green blue:&blue alpha:&alpha];

    red = MAX(0.0, red - colorDelta);
    green = MAX(0.0, green - colorDelta);
    blue = MAX(0.0, blue - colorDelta);

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark -  Private

- (void)setColorscheme:(AppearanceManagerColorscheme)colorscheme
{
    _colorscheme = colorscheme;

    UIColor *textMainColor = [self textMainColorForScheme:colorscheme];

    [[UIButton appearance] setTintColor:textMainColor];
    [[UISwitch appearance] setOnTintColor:textMainColor];
}

@end
