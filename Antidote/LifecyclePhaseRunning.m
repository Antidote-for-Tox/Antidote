//
//  LifecyclePhaseRunning.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <objcTox/OCTManager.h>
#import <objcTox/OCTSubmanagerBootstrap.h>
#import <objcTox/RBQFetchedResultsController.h>

#import "LifecyclePhaseRunning.h"
#import "LifecyclePhaseLogin.h"
#import "RunningContext.h"
#import "UserDefaultsManager.h"
#import "TabBarViewController.h"
#import "Helper.h"
#import "AppDelegate.h"
#import "ToxListener.h"

@interface LifecyclePhaseRunning ()

@property (strong, nonatomic) OCTManager *toxManager;
@property (strong, nonatomic) ToxListener *toxListener;

@end

@implementation LifecyclePhaseRunning
@synthesize delegate = _delegate;

#pragma mark -  Lifecycle

- (instancetype)initWithToxManager:(OCTManager *)manager
{
    NSParameterAssert(manager);

    self = [super init];

    if (! self) {
        return nil;
    }

    _toxManager = manager;

    return self;
}

#pragma mark -  Public

- (void)logout
{
    [RunningContext kill];
    [AppContext sharedContext].userDefaults.uIsUserLoggedIn = NO;

    [self.delegate phaseDidFinish:self withNextPhase:[LifecyclePhaseLogin new]];
}

#pragma mark -  LifecyclePhaseProtocol

- (void)start
{
    [self.toxManager.bootstrap addPredefinedNodes];
    [self.toxManager.bootstrap bootstrap];

    [RunningContext createWithManager:self.toxManager];

    TabBarViewController *tabBarVC = [self createTabBarController];

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.window.rootViewController = tabBarVC;
    [RunningContext context].tabBarController = tabBarVC;

    self.toxListener = [[ToxListener alloc] initWithManager:self.toxManager];
    [self.toxListener performUpdates];
}

- (nonnull NSString *)name
{
    return @"Running";
}

#pragma mark -  Private

- (TabBarViewController *)createTabBarController
{
    RBQFetchedResultsController *chats = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeChat delegate:nil];
    RBQFetchedResultsController *friends = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeFriend delegate:nil];
    RBQFetchedResultsController *friendRequests = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeFriendRequest delegate:nil];

    TabBarViewController *tabBarVC = [TabBarViewController new];

    if ([chats numberOfRowsForSectionIndex:0]) {
        tabBarVC.selectedIndex = TabBarViewControllerIndexChats;
    }
    else if ([friends numberOfRowsForSectionIndex:0] ||
             [friendRequests numberOfRowsForSectionIndex:0]) {
        tabBarVC.selectedIndex = TabBarViewControllerIndexFriends;
    }
    else {
        tabBarVC.selectedIndex = TabBarViewControllerIndexProfile;
    }

    return tabBarVC;
}

@end
