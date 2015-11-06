//
//  RunningContext.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OCTManager;
@class CallsManager;
@class NotificationManager;
@class TabBarViewController;

/**
 * Running context contains various objects related to running phase. If alive only
 * during LifecyclePhaseRunning.
 */
@interface RunningContext : NSObject

@property (weak, nonatomic, readonly) OCTManager *toxManager;
@property (weak, nonatomic) TabBarViewController *tabBarController;

@property (strong, nonatomic, readonly) NotificationManager *notificationManager;
@property (strong, nonatomic, readonly) CallsManager *calls;

+ (instancetype)context;

+ (void)createWithManager:(OCTManager *)manager;
+ (void)kill;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (void)killCallsManager;

@end
