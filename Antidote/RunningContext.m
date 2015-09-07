//
//  RunningContext.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <objcTox/OCTManager.h>

#import "RunningContext.h"
#import "NotificationManager.h"
#import "TabBarViewController.h"

static RunningContext *_runningContext;
static NSObject *_runningContextLock;

@interface RunningContext ()

@property (weak, nonatomic, readwrite) OCTManager *toxManager;

@property (strong, nonatomic, readwrite) NotificationManager *notificationManager;

@end

@implementation RunningContext

#pragma mark -  Class methods

+ (instancetype)context
{
    @synchronized(_runningContextLock) {
        return _runningContext;
    }
}

+ (void)createWithManager:(OCTManager *)manager
{
    @synchronized(_runningContextLock) {
        _runningContext = [super new];
        _runningContext.toxManager = manager;
        _runningContext.notificationManager = [NotificationManager new];
    }
}

+ (void)kill
{
    @synchronized(_runningContextLock) {
        _runningContext = nil;
    }
}

@end
