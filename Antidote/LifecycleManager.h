//
//  LifecycleManager.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LifecyclePhaseProtocol;

@interface LifecycleManager : NSObject

/**
 * This method will take effect only once during manager's existence. It should be called
 * before any other methods of LifecycleManager.
 */
- (void)start;

- (nonnull id<LifecyclePhaseProtocol>)currentPhase;

- (void)handleIncomingFileURL:(nonnull NSURL *)url;

@end
