//
//  LifecyclePhaseRunning.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <objcTox/OCTManager.h>
#import <objcTox/OCTManagerConfiguration.h>
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
#import "GlobalConstants.h"
#import "ProfileManager.h"
#import "ErrorHandler.h"

@interface LifecyclePhaseRunning ()

@property (strong, nonatomic) OCTManager *toxManager;
@property (strong, nonatomic) ToxListener *toxListener;

@end

@implementation LifecyclePhaseRunning
@synthesize delegate = _delegate;

#pragma mark -  Lifecycle

- (nullable instancetype)initWithToxManager:(nonnull OCTManager *)manager
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

- (void)reloginAndPerformBlock:(nullable void (^)())block
{
    NSString *profileName = [AppContext sharedContext].userDefaults.uLastActiveProfile;
    NSString *passphrase = self.toxManager.configuration.passphrase;

    ProfileManager *profileManager = [ProfileManager new];

    OCTManagerConfiguration *configuration = [profileManager configurationForProfileWithName:profileName
                                                                                  passphrase:passphrase];

    NSError *error;
    OCTManager *manager = [[OCTManager alloc] initWithConfiguration:configuration error:&error];

    if (manager) {
        [self prepareToBeKilled];

        LifecyclePhaseRunning *running = [[LifecyclePhaseRunning alloc] initWithToxManager:manager];
        [self.delegate phaseDidFinish:self withNextPhase:running];

        if (block) {
            block();
        }
    }
    else {
        [[AppContext sharedContext].errorHandler handleError:error type:ErrorHandlerTypeCreateOCTManager];
        [self logout];
    }
}

- (void)logout
{
    [self prepareToBeKilled];

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

- (void)handleIncomingFileURL:(nonnull NSURL *)url
                      options:(LifecyclePhaseIncomingFileOption)options
                   completion:(nonnull void (^)(BOOL didHandle, LifecyclePhaseIncomingFileOption options))completionBlock
{
    if ([url.pathExtension isEqualToString:kToxSaveFileExtension]) {
        NSString *message = [NSString stringWithFormat:
                             NSLocalizedString(@"Import \"%@\" as tox profile?", @"LifecyclePhaseRunning"),
                             [url lastPathComponent]];

        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:nil message:message];

        [alert bk_addButtonWithTitle:NSLocalizedString(@"Yes", @"LifecyclePhaseRunning") handler:^{
            completionBlock(NO, options | LifecyclePhaseIncomingFileOptionImportProfile);
            [self logout];
        }];

        [alert bk_setCancelButtonWithTitle:NSLocalizedString(@"No", @"LifecyclePhaseRunning") handler:^{
            // TODO file transfers
            completionBlock(YES, options);
        }];
        [alert show];
    }
    else {
        // TODO file transfers
        completionBlock(YES, options);
    }
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

- (void)prepareToBeKilled
{
    [RunningContext kill];
}

@end
