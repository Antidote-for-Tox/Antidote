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
@class FileManager;
@class LifecycleManager;
@class UserDefaultsManager;

@interface AppContext : NSObject

+ (instancetype)sharedContext;

@property (strong, nonatomic, readonly) AppearanceManager *appearance;
@property (strong, nonatomic, readonly) AvatarsManager *avatars;
@property (strong, nonatomic, readonly) ErrorHandler *errorHandler;
@property (strong, nonatomic, readonly) FileManager *fileManager;
@property (strong, nonatomic, readonly) LifecycleManager *lifecycleManager;
@property (strong, nonatomic, readonly) UserDefaultsManager *userDefaults;

- (void)restoreDefaultSettings;

@end
