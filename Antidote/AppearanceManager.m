//
//  AppearanceManager.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 07.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "AppearanceManager.h"
#import "UIColor+Utilities.h"

@interface AppearanceManager()

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

- (UIColor *)textMainColor
{
    return [self textMainColorForScheme:self.colorscheme];
}

- (UIColor *)statusOfflineColor
{
    return [UIColor uColorOpaqueWithWhite:170];
}

- (UIColor *)statusOnlineColor;
{
    switch(self.colorscheme) {
        case AppearanceManagerColorschemeRed:
            return [UIColor uColorOpaqueWithRed:56 green:130 blue:87];

        case AppearanceManagerColorschemeIce:
            return [UIColor uColorOpaqueWithRed:133 green:180 blue:82];

        case AppearanceManagerColorschemeOrange:
            return [UIColor uColorOpaqueWithRed:117 green:142 blue:86];

        case AppearanceManagerColorschemePurple:
            return [UIColor uColorOpaqueWithRed:102 green:146 blue:87];

        case __AppearanceManagerColorschemeCount:
            NSAssert(NO, @"We shouldn't be here");
            return nil;
    }
}

- (UIColor *)statusAwayColor;
{
    switch(self.colorscheme) {
        case AppearanceManagerColorschemeRed:
            return [UIColor uColorOpaqueWithRed:233 green:225 blue:129];

        case AppearanceManagerColorschemeIce:
            return [UIColor uColorOpaqueWithRed:222 green:207 blue:78];

        case AppearanceManagerColorschemeOrange:
            return [UIColor uColorOpaqueWithRed:245 green:234 blue:57];

        case AppearanceManagerColorschemePurple:
            return [UIColor uColorOpaqueWithRed:244 green:243 blue:143];

        case __AppearanceManagerColorschemeCount:
            NSAssert(NO, @"We shouldn't be here");
            return nil;
    }
}

- (UIColor *)statusBusyColor;
{
    switch(self.colorscheme) {
        case AppearanceManagerColorschemeRed:
            return [UIColor uColorOpaqueWithRed:233 green:225 blue:129];

        case AppearanceManagerColorschemeIce:
            return [UIColor uColorOpaqueWithRed:197 green:98 blue:88];

        case AppearanceManagerColorschemeOrange:
            return [UIColor uColorOpaqueWithRed:156 green:72 blue:69];

        case AppearanceManagerColorschemePurple:
            return [UIColor uColorOpaqueWithRed:152 green:88 blue:109];

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
    switch(self.colorscheme) {
        case AppearanceManagerColorschemeRed:
            return [UIColor uColorOpaqueWithRed:236 green:244 blue:248];

        case AppearanceManagerColorschemeIce:
            return [UIColor uColorOpaqueWithRed:248 green:248 blue:237];

        case AppearanceManagerColorschemeOrange:
            return [UIColor uColorOpaqueWithRed:242 green:240 blue:236];

        case AppearanceManagerColorschemePurple:
            return [UIColor uColorOpaqueWithRed:235 green:240 blue:229];

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
    switch(self.colorscheme) {
        case AppearanceManagerColorschemeRed:
            return [UIColor uColorWithRed:249 green:244 blue:244 alpha:alpha];

        case AppearanceManagerColorschemeIce:
            return [UIColor uColorWithRed:240 green:245 blue:247 alpha:alpha];

        case AppearanceManagerColorschemeOrange:
            return [UIColor uColorWithRed:249 green:246 blue:241 alpha:alpha];

        case AppearanceManagerColorschemePurple:
            return [UIColor uColorWithRed:243 green:241 blue:247 alpha:alpha];

        case __AppearanceManagerColorschemeCount:
            NSAssert(NO, @"We shouldn't be here");
            return nil;
    }
}

- (UIColor *)textMainColorForScheme:(AppearanceManagerColorscheme)scheme
{
    switch(scheme) {
        case AppearanceManagerColorschemeRed:
            return [UIColor uColorOpaqueWithRed:229 green:84 blue:81];

        case AppearanceManagerColorschemeIce:
            return [UIColor uColorOpaqueWithRed:38 green:133 blue:172];

        case AppearanceManagerColorschemeOrange:
            return [UIColor uColorOpaqueWithRed:245 green:156 blue:37];

        case AppearanceManagerColorschemePurple:
            return [UIColor uColorOpaqueWithRed:82 green:58 blue:175];

        case __AppearanceManagerColorschemeCount:
            NSAssert(NO, @"We shouldn't be here");
            return nil;
    }
}

- (UIColor *)bubbleIncomingColorForScheme:(AppearanceManagerColorscheme)scheme
{
    switch(scheme) {
        case AppearanceManagerColorschemeRed:
            return [UIColor uColorOpaqueWithRed:204 green:217 blue:230];

        case AppearanceManagerColorschemeIce:
            return [UIColor uColorOpaqueWithRed:247 green:242 blue:203];

        case AppearanceManagerColorschemeOrange:
            return [UIColor uColorOpaqueWithRed:232 green:226 blue:202];

        case AppearanceManagerColorschemePurple:
            return [UIColor uColorOpaqueWithRed:212 green:225 blue:208];

        case __AppearanceManagerColorschemeCount:
            NSAssert(NO, @"We shouldn't be here");
            return nil;
    }
}

#pragma mark -  Private

- (void)setColorscheme:(AppearanceManagerColorscheme)colorscheme
{
    _colorscheme = colorscheme;

    [[UIButton appearance] setTintColor:[self textMainColorForScheme:colorscheme]];
}

@end
