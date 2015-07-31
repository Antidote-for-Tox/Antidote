//
//  AppContext.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 19.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppearanceManager;
@class AvatarsManager;
@class ErrorHandler;
@class NotificationManager;
@class ProfileManager;
@class TabBarViewController;
@class UserDefaultsManager;

@interface AppContext : NSObject

+ (instancetype)sharedContext;

@property (strong, nonatomic, readonly) AppearanceManager *appearance;
@property (strong, nonatomic, readonly) AvatarsManager *avatars;
@property (strong, nonatomic, readonly) ErrorHandler *errorHandler;
@property (strong, nonatomic, readonly) NotificationManager *notification;
@property (strong, nonatomic, readonly) ProfileManager *profileManager;
@property (strong, nonatomic, readonly) TabBarViewController *tabBarController;
@property (strong, nonatomic, readonly) UserDefaultsManager *userDefaults;

- (void)restoreDefaultSettings;
- (void)recreateAppearance;
- (void)recreateTabBarController;

@end
