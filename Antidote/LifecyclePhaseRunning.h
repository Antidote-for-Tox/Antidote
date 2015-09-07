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

- (instancetype)initWithToxManager:(OCTManager *)manager;

- (void)logout;

@end
