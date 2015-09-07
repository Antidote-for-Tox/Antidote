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

@property (strong, nonatomic, readwrite) OCTManager *toxManager;
@property (strong, nonatomic, readwrite) NotificationManager *notificationManager;
@property (strong, nonatomic, readwrite) TabBarViewController *tabBarController;

@end

@implementation RunningContext

#pragma mark -  Class methods

+ (instancetype)context
{
    @synchronized(_runningContextLock) {
        return _runningContext;
    }
}

+ (void)createWithManager:(OCTManager *)manager tabBarController:(TabBarViewController *)tabBarController
{
    @synchronized(_runningContextLock) {
        _runningContext = [super new];
        _runningContext.toxManager = manager;
        _runningContext.notificationManager = [NotificationManager new];
        _runningContext.tabBarController = tabBarController;
    }
}

+ (void)kill
{
    @synchronized(_runningContextLock) {
        _runningContext = nil;
    }
}

@end
