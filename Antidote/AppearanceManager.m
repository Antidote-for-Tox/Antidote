//
//  AppearanceManager.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 07.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "AppearanceManager.h"
#import "UserInfoManager.h"
#import "UIColor+Utilities.h"

@interface AppearanceManager()

@property (assign, nonatomic) AppearanceManagerColorscheme colorscheme;

@end

@implementation AppearanceManager

#pragma mark -  Lifecycle

- (id)init
{
    return nil;
}

- (id)initPrivate
{
    if (self = [super init]) {
        NSNumber *colorscheme = [UserInfoManager sharedInstance].uCurrentColorscheme;

        if (colorscheme) {
            self.colorscheme = colorscheme.unsignedIntegerValue;
        }
        else {
            // default
            self.colorscheme = AppearanceManagerColorschemeRed;
        }
    }

    return self;
}

+ (AppearanceManager *)sharedInstance
{
    static AppearanceManager *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[AppearanceManager alloc] initPrivate];
    });

    return instance;
}

- (void)setColorscheme:(AppearanceManagerColorscheme)colorscheme
{
    _colorscheme = colorscheme;

    [[UIButton appearance] setTintColor:[[self class] textMainColorForScheme:colorscheme]];
}

#pragma mark -  Public

+ (UIFont *)fontHelveticaNeueWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

+ (UIFont *)fontHelveticaNeueLightWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
}

+ (UIFont *)fontHelveticaNeueBoldWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
}

+ (AppearanceManagerColorscheme)colorscheme
{
    return [self sharedInstance].colorscheme;
}

+ (void)changeColorschemeTo:(AppearanceManagerColorscheme)newColorscheme
{
    [self sharedInstance].colorscheme = newColorscheme;

    [UserInfoManager sharedInstance].uCurrentColorscheme = @(newColorscheme);
}

+ (UIColor *)textMainColor
{
    return [self textMainColorForScheme:self.colorscheme];
}

+ (UIColor *)statusOfflineColor
{
    return [UIColor uColorOpaqueWithWhite:170];
}

+ (UIColor *)statusOnlineColor;
{
    if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeRed) {
        return [UIColor uColorOpaqueWithRed:56 green:130 blue:87];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeIce) {
        return [UIColor uColorOpaqueWithRed:133 green:180 blue:82];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeOrange) {
        return [UIColor uColorOpaqueWithRed:117 green:142 blue:86];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemePurple) {
        return [UIColor uColorOpaqueWithRed:102 green:146 blue:87];
    }

    return nil;
}

+ (UIColor *)statusAwayColor;
{
    if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeRed) {
        return [UIColor uColorOpaqueWithRed:233 green:225 blue:129];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeIce) {
        return [UIColor uColorOpaqueWithRed:222 green:207 blue:78];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeOrange) {
        return [UIColor uColorOpaqueWithRed:245 green:234 blue:57];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemePurple) {
        return [UIColor uColorOpaqueWithRed:244 green:243 blue:143];
    }

    return nil;
}

+ (UIColor *)statusBusyColor;
{
    if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeRed) {
        return [UIColor uColorOpaqueWithRed:180 green:83 blue:81];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeIce) {
        return [UIColor uColorOpaqueWithRed:197 green:98 blue:88];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeOrange) {
        return [UIColor uColorOpaqueWithRed:156 green:72 blue:69];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemePurple) {
        return [UIColor uColorOpaqueWithRed:152 green:88 blue:109];
    }

    return nil;
}

+ (UIColor *)bubbleIncomingColor;
{
    return [self bubbleIncomingColorForScheme:self.colorscheme];
}

+ (UIColor *)bubbleOutgoingColor
{
    if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeRed) {
        return [UIColor uColorOpaqueWithRed:236 green:244 blue:248];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeIce) {
        return [UIColor uColorOpaqueWithRed:248 green:248 blue:237];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeOrange) {
        return [UIColor uColorOpaqueWithRed:242 green:240 blue:236];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemePurple) {
        return [UIColor uColorOpaqueWithRed:235 green:240 blue:229];
    }

    return nil;
}

+ (UIColor *)unreadChatCellBackground
{
    return [self unreadChatCellBackgroundWithAlpha:1.0];
}

+ (UIColor *)unreadChatCellBackgroundWithAlpha:(CGFloat)alpha
{
    if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeRed) {
        return [UIColor uColorWithRed:249 green:244 blue:244 alpha:alpha];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeIce) {
        return [UIColor uColorWithRed:240 green:245 blue:247 alpha:alpha];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeOrange) {
        return [UIColor uColorWithRed:249 green:246 blue:241 alpha:alpha];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemePurple) {
        return [UIColor uColorWithRed:243 green:241 blue:247 alpha:alpha];
    }

    return nil;
}

+ (UIColor *)textMainColorForScheme:(AppearanceManagerColorscheme)scheme
{
    if (scheme == AppearanceManagerColorschemeRed) {
        return [UIColor uColorOpaqueWithRed:229 green:84 blue:81];
    }
    else if (scheme == AppearanceManagerColorschemeIce) {
        return [UIColor uColorOpaqueWithRed:38 green:133 blue:172];
    }
    else if (scheme == AppearanceManagerColorschemeOrange) {
        return [UIColor uColorOpaqueWithRed:245 green:156 blue:37];
    }
    else if (scheme == AppearanceManagerColorschemePurple) {
        return [UIColor uColorOpaqueWithRed:82 green:58 blue:175];
    }

    return nil;
}

+ (UIColor *)bubbleIncomingColorForScheme:(AppearanceManagerColorscheme)scheme
{
    if (scheme == AppearanceManagerColorschemeRed) {
        return [UIColor uColorOpaqueWithRed:204 green:217 blue:230];
    }
    else if (scheme == AppearanceManagerColorschemeIce) {
        return [UIColor uColorOpaqueWithRed:247 green:242 blue:203];
    }
    else if (scheme == AppearanceManagerColorschemeOrange) {
        return [UIColor uColorOpaqueWithRed:232 green:226 blue:202];
    }
    else if (scheme == AppearanceManagerColorschemePurple) {
        return [UIColor uColorOpaqueWithRed:212 green:225 blue:208];
    }

    return nil;
}

@end
