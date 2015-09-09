//
//  LifecyclePhaseLogin.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "LifecyclePhaseProtocol.h"

@class OCTManager;

@interface LifecyclePhaseLogin : NSObject <LifecyclePhaseProtocol>

- (void)finishPhaseWithToxManager:(nonnull OCTManager *)manager profileName:(nonnull NSString *)profileName;

@end
