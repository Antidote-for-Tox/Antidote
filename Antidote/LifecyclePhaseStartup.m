//
//  LifecyclePhaseStartup.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "LifecyclePhaseStartup.h"
#import "LifecyclePhaseLogin.h"

@implementation LifecyclePhaseStartup
@synthesize delegate = _delegate;

#pragma mark -  LifecyclePhaseProtocol

- (void)start
{
    [self.delegate phaseDidFinish:self withNextPhase:[LifecyclePhaseLogin new]];
}

- (nonnull NSString *)name
{
    return @"Startup";
}

- (void)handleIncomingFileURL:(nonnull NSURL *)url
                      options:(LifecyclePhaseIncomingFileOption)options
                   completion:(nonnull void (^)(BOOL didHandle, LifecyclePhaseIncomingFileOption options))completionBlock
{
    completionBlock(NO, options);
}

@end
