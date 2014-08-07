//
//  AppDelegate.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 18.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#define MR_ENABLE_ACTIVE_RECORD_LOGGING 0

#import "AppDelegate.h"
#import "ToxManager.h"
#import "AllChatsViewController.h"
#import "FriendsViewController.h"
#import "SettingsViewController.h"
#import "CoreData+MagicalRecord.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"DataStore.sqlite"];

    [[ToxManager sharedInstance] bootstrapWithAddress:@"23.226.230.47"
                                                 port:33445
                                            publicKey:@"A09162D68618E742FFBCA1C2C70385E6679604B2D80EA6E84AD0996A1AC8A074"];

    [self recreateControllersAndShow:AppDelegateTabIndexChats];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)recreateControllersAndShow:(AppDelegateTabIndex)tabIndex
{
    UINavigationController *allChats = [[UINavigationController alloc] initWithRootViewController:[AllChatsViewController new]];
    UINavigationController *friends = [[UINavigationController alloc] initWithRootViewController:[FriendsViewController new]];
    UINavigationController *settings = [[UINavigationController alloc] initWithRootViewController:[SettingsViewController new]];

    UITabBarController *tabBar = [UITabBarController new];
    tabBar.viewControllers = @[allChats, friends, settings];

    allChats.navigationBar.tintColor =
    friends.navigationBar.tintColor  =
    settings.navigationBar.tintColor =
    tabBar.tabBar.tintColor          = [AppearanceManager textMainColor];

    allChats.tabBarItem = [[UITabBarItem alloc] initWithTitle:allChats.title
                                                        image:[UIImage imageNamed:@"tab-bar-chats"]
                                                          tag:AppDelegateTabIndexChats];

    friends.tabBarItem = [[UITabBarItem alloc] initWithTitle:friends.title
                                                       image:[UIImage imageNamed:@"tab-bar-friends"]
                                                         tag:AppDelegateTabIndexFriends];

    settings.tabBarItem = [[UITabBarItem alloc] initWithTitle:settings.title
                                                        image:[UIImage imageNamed:@"tab-bar-settings"]
                                                          tag:AppDelegateTabIndexSettings];

    tabBar.selectedIndex = tabIndex;

    self.window.rootViewController = tabBar;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}

@end
