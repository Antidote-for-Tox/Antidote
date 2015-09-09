//
//  LifecyclePhaseLogin.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <objcTox/OCTManager.h>

#import "LifecyclePhaseLogin.h"
#import "LoginViewController.h"
#import "LifecyclePhaseRunning.h"
#import "UserDefaultsManager.h"
#import "ProfileManager.h"
#import "AppDelegate.h"
#import "AppearanceManager.h"

@interface LifecyclePhaseLogin () <UINavigationControllerDelegate>

@end

@implementation LifecyclePhaseLogin
@synthesize delegate = _delegate;

#pragma mark -  Public

- (void)finishPhaseWithToxManager:(nonnull OCTManager *)manager profileName:(nonnull NSString *)profileName
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

    [AppContext sharedContext].userDefaults.uIsUserLoggedIn = YES;
    [AppContext sharedContext].userDefaults.uLastActiveProfile = profileName;

    LifecyclePhaseRunning *running = [[LifecyclePhaseRunning alloc] initWithToxManager:manager];

    [self.delegate phaseDidFinish:self withNextPhase:running];
}

#pragma mark -  LifecyclePhaseProtocol

- (void)start
{
    BOOL isLoggedIn = [AppContext sharedContext].userDefaults.uIsUserLoggedIn;
    NSString *lastActiveProfile = [AppContext sharedContext].userDefaults.uLastActiveProfile;

    if (! isLoggedIn || ! lastActiveProfile) {
        [self showLoginController];
        return;
    }

    ProfileManager *profileManager = [ProfileManager new];

    if (! [profileManager.allProfiles containsObject:lastActiveProfile]) {
        [self showLoginController];
        return;
    }

    OCTManagerConfiguration *configuration = [profileManager configurationForProfileWithName:lastActiveProfile];

    if (! configuration) {
        [self showLoginController];
        return;
    }

    OCTManager *manager = [[OCTManager alloc] initWithConfiguration:configuration error:nil];

    if (! manager) {
        [self showLoginController];
        return;
    }

    [self finishPhaseWithToxManager:manager profileName:lastActiveProfile];
}

- (nonnull NSString *)name
{
    return @"Login";
}

#pragma mark -  UINavigationControllerDelegate

- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController
{
    return [navigationController.topViewController supportedInterfaceOrientations];
}

#pragma mark -  Private

- (void)showLoginController
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

    NSString *activeProfile = [AppContext sharedContext].userDefaults.uLastActiveProfile;

    LoginViewController *loginVC = [[LoginViewController alloc] initWithActiveProfile:activeProfile];
    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:loginVC];
    navCon.delegate = self;
    navCon.navigationBar.tintColor = [UIColor whiteColor];
    navCon.navigationBar.barTintColor = [[AppContext sharedContext].appearance loginNavigationBarColor];
    [navCon.navigationBar setTitleTextAttributes:@{
         NSForegroundColorAttributeName : [UIColor whiteColor]
     }];

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.window.rootViewController = navCon;
}

@end
