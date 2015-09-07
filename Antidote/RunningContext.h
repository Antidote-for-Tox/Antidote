//
//  RunningContext.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OCTManager;
@class NotificationManager;
@class TabBarViewController;

/**
 * Running context contains various objects related to running phase. If alive only
 * during LifecyclePhaseRunning.
 */
@interface RunningContext : NSObject

@property (strong, nonatomic, readonly) OCTManager *toxManager;
@property (strong, nonatomic, readonly) NotificationManager *notificationManager;
@property (strong, nonatomic, readonly) TabBarViewController *tabBarController;

+ (instancetype)context;

+ (void)createWithManager:(OCTManager *)manager tabBarController:(TabBarViewController *)tabBarController;
+ (void)kill;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
