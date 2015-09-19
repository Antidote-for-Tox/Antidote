//
//  LifecyclePhaseRunning.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "LifecyclePhaseProtocol.h"

@class OCTManager;

@interface LifecyclePhaseRunning : NSObject <LifecyclePhaseProtocol>

- (nullable instancetype)initWithToxManager:(nonnull OCTManager *)manager;

/**
 * Running phase logs out and immediately creates new running phase with copy of the OCTManager.
 * RunningContext and all related objects are recreated.
 *
 * @param block Block to perform after relogin. You can use is to perform custom actions, e.g. move to different
 * tab, push some view controllers, etc.
 */
- (void)reloginAndPerformBlock:(nullable void (^)())block;

/**
 * Logs out switching to Login phase.
 */
- (void)logout;
- (void)logoutWithCompletionBlock:(nullable void (^)())completionBlock;

@end
