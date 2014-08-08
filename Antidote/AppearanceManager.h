//
//  AppearanceManager.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 07.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AppearanceManagerColorscheme) {
    AppearanceManagerColorschemeRed = 0,
    AppearanceManagerColorschemeIce,
    AppearanceManagerColorschemeOrange,
    AppearanceManagerColorschemePurple,
    __AppearanceManagerColorschemeCount,
};

@interface AppearanceManager : NSObject

+ (UIFont *)fontHelveticaNeueWithSize:(CGFloat)size;
+ (UIFont *)fontHelveticaNeueLightWithSize:(CGFloat)size;

+ (AppearanceManagerColorscheme)colorscheme;
+ (void)changeColorschemeTo:(AppearanceManagerColorscheme)newColorscheme;

+ (UIColor *)textMainColor;

+ (UIColor *)statusOfflineColor;
+ (UIColor *)statusOnlineColor;
+ (UIColor *)statusAwayColor;
+ (UIColor *)statusBusyColor;

+ (UIColor *)bubbleIncomingColor;
+ (UIColor *)bubbleOutgoingColor;

+ (UIColor *)textMainColorForScheme:(AppearanceManagerColorscheme)scheme;
+ (UIColor *)bubbleIncomingColorForScheme:(AppearanceManagerColorscheme)scheme;

@end
