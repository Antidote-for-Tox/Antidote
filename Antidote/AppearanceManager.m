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

#pragma mark -  Public

+ (AppearanceManagerColorscheme)colorscheme
{
    return [self sharedInstance].colorscheme;
}

+ (UIColor *)textMainColor
{
    if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeRed) {
        return [UIColor uColorOpaqueWithRed:229 green:84 blue:81];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeIce) {
        return [UIColor uColorOpaqueWithRed:38 green:133 blue:172];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeOrange) {
        return [UIColor uColorOpaqueWithRed:255 green:166 blue:47];
    }

    return nil;
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

    return nil;
}

+ (UIColor *)bubbleIncomingColor;
{
    if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeRed) {
        return [UIColor uColorOpaqueWithRed:204 green:217 blue:230];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeIce) {
        return [UIColor uColorOpaqueWithRed:247 green:242 blue:203];
    }
    else if ([self sharedInstance].colorscheme == AppearanceManagerColorschemeOrange) {
        return [UIColor uColorOpaqueWithRed:239 green:227 blue:207];
    }

    return nil;
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
        return [UIColor uColorOpaqueWithRed:239 green:236 blue:231];
    }

    return nil;
}
@end
