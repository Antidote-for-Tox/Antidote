//
//  AppearanceManager.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 07.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AppearanceManagerColorscheme) {
    AppearanceManagerColorschemeRed,
    AppearanceManagerColorschemeIce,
    AppearanceManagerColorschemeOrange,
    AppearanceManagerColorschemePurple,
};

@interface AppearanceManager : NSObject

+ (AppearanceManagerColorscheme)colorscheme;

+ (UIColor *)textMainColor;

+ (UIColor *)statusOfflineColor;
+ (UIColor *)statusOnlineColor;
+ (UIColor *)statusAwayColor;
+ (UIColor *)statusBusyColor;

+ (UIColor *)bubbleIncomingColor;
+ (UIColor *)bubbleOutgoingColor;

@end
