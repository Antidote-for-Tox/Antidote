//
//  LifecycleManager.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "LifecycleManager.h"
#import "LifecyclePhaseProtocol.h"
#import "LifecyclePhaseStartup.h"

@interface LifecycleManager () <LifecyclePhaseDelegate>

@property (strong, nonatomic, nonnull) id<LifecyclePhaseProtocol> phase;
@property (strong, nonatomic) NSObject *phaseLockObject;
@property (assign, nonatomic) dispatch_once_t startOnceToken;

@end

@implementation LifecycleManager

#pragma mark -  Public

- (void)start
{
    dispatch_once(&_startOnceToken, ^{
        self.phaseLockObject = [NSObject new];
        [self runNextPhase:[LifecyclePhaseStartup new]];
    });
}

- (nonnull id<LifecyclePhaseProtocol>)currentPhase
{
    @synchronized(self.phaseLockObject) {
        return self.phase;
    }
}

#pragma mark -  LifecyclePhaseDelegate

- (void)phaseDidFinish:(nonnull id<LifecyclePhaseProtocol>)phase withNextPhase:(nonnull id<LifecyclePhaseProtocol>)nextPhase
{
    [self runNextPhase:nextPhase];
}

#pragma mark -  Private

- (void)runNextPhase:(id<LifecyclePhaseProtocol>)phase
{
    @synchronized(self.phaseLockObject) {
        DDLogInfo(@"Running phase: %@", [phase name]);

        self.phase = phase;
        phase.delegate = self;
        [phase start];
    }
}

@end
