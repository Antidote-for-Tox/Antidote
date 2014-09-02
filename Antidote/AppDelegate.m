//
//  AppDelegate.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 18.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#define MR_ENABLE_ACTIVE_RECORD_LOGGING 0

#import "AppDelegate.h"
#import "CustomLogFormatter.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "ToxManager.h"
#import "AllChatsViewController.h"
#import "FriendsViewController.h"
#import "SettingsViewController.h"
#import "CoreData+MagicalRecord.h"
#import "CoreDataManager+Chat.h"
#import "CoreDataManager+Message.h"
#import "BadgeWithText.h"

@interface AppDelegate()

@property (strong, nonatomic) BadgeWithText *friendsBadge;
@property (strong, nonatomic) BadgeWithText *chatsBadge;

@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    [self configureLoggingStuff];

    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"DataStore.sqlite"];

    [[ToxManager sharedInstance] bootstrapWithNodes:@[
        [ToxNode nodeWithAddress:@"192.254.75.98"   port:33445 publicKey:@"951C88B7E75C867418ACDB5D273821372BB5BD652740BCDF623A4FA293E75D2F"],
        [ToxNode nodeWithAddress:@"107.161.17.51"   port:33445 publicKey:@"7BE3951B97CA4B9ECDDA768E8C52BA19E9E2690AB584787BF4C90E04DBB75111"],
        [ToxNode nodeWithAddress:@"144.76.60.215"   port:33445 publicKey:@"04119E835DF3E78BACF0F84235B300546AF8B936F035185E2A8E9E0A67C8924F"],
        [ToxNode nodeWithAddress:@"23.226.230.47"   port:33445 publicKey:@"A09162D68618E742FFBCA1C2C70385E6679604B2D80EA6E84AD0996A1AC8A074"],
        [ToxNode nodeWithAddress:@"37.59.102.176"   port:33445 publicKey:@"B98A2CEAA6C6A2FADC2C3632D284318B60FE5375CCB41EFA081AB67F500C1B0B"],
        [ToxNode nodeWithAddress:@"37.187.46.132"   port:33445 publicKey:@"5EB67C51D3FF5A9D528D242B669036ED2A30F8A60E674C45E7D43010CB2E1331"],
        [ToxNode nodeWithAddress:@"178.21.112.187"  port:33445 publicKey:@"4B2C19E924972CB9B57732FB172F8A8604DE13EEDA2A6234E348983344B23057"],
        [ToxNode nodeWithAddress:@"192.210.149.121" port:33445 publicKey:@"F404ABAA1C99A9D37D61AB54898F56793E1DEF8BD46B1038B9D822E8460FAB67"],
        [ToxNode nodeWithAddress:@"54.199.139.199"  port:33445 publicKey:@"7F9C31FE850E97CEFD4C4591DF93FC757C7C12549DDD55F8EEAECC34FE76C029"],
    ]];

    [self recreateControllersAndShow:AppDelegateTabIndexChats];

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)recreateControllersAndShow:(AppDelegateTabIndex)tabIndex
{
    UINavigationController *friends = [[UINavigationController alloc] initWithRootViewController:[FriendsViewController new]];
    UINavigationController *allChats = [[UINavigationController alloc] initWithRootViewController:[AllChatsViewController new]];
    UINavigationController *settings = [[UINavigationController alloc] initWithRootViewController:[SettingsViewController new]];

    UITabBarController *tabBar = [UITabBarController new];
    tabBar.viewControllers = @[friends, allChats, settings];

    friends.navigationBar.tintColor  =
    allChats.navigationBar.tintColor =
    settings.navigationBar.tintColor =
    tabBar.tabBar.tintColor          = [AppearanceManager textMainColor];

    friends.tabBarItem = [[UITabBarItem alloc] initWithTitle:friends.title
                                                       image:[UIImage imageNamed:@"tab-bar-friends"]
                                                         tag:AppDelegateTabIndexFriends];

    allChats.tabBarItem = [[UITabBarItem alloc] initWithTitle:allChats.title
                                                        image:[UIImage imageNamed:@"tab-bar-chats"]
                                                          tag:AppDelegateTabIndexChats];

    settings.tabBarItem = [[UITabBarItem alloc] initWithTitle:settings.title
                                                        image:[UIImage imageNamed:@"tab-bar-settings"]
                                                          tag:AppDelegateTabIndexSettings];

    tabBar.selectedIndex = tabIndex;

    self.window.rootViewController = tabBar;

    self.friendsBadge = [self addBadgeAtIndex:AppDelegateTabIndexFriends];
    self.chatsBadge = [self addBadgeAtIndex:AppDelegateTabIndexChats];

    [self updateBadgeForTab:AppDelegateTabIndexFriends];
    [self updateBadgeForTab:AppDelegateTabIndexChats];
}

- (BadgeWithText *)addBadgeAtIndex:(NSUInteger)index
{
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;

    CGRect frame = CGRectZero;
    frame.origin.x = index * (tabBarController.tabBar.frame.size.width / 3) +
        tabBarController.tabBar.frame.size.width / 6;
    frame.origin.y = 3.0;

    BadgeWithText *badge = [[BadgeWithText alloc] initWithFrame:frame];
    badge.backgroundColor = [AppearanceManager statusBusyColor];
    [tabBarController.tabBar addSubview:badge];

    return badge;
}

- (void)updateBadgeForTab:(AppDelegateTabIndex)tabIndex
{
    if (tabIndex == AppDelegateTabIndexFriends) {
        NSUInteger number = [[ToxManager sharedInstance].friendsContainer requestsCount];

        self.friendsBadge.value = number ? [NSString stringWithFormat:@"%lu", (unsigned long)number] : nil;
    }
    else if (tabIndex == AppDelegateTabIndexChats) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastMessage.date > lastReadDate"];

        __weak AppDelegate *weakSelf = self;

        [CoreDataManager chatsWithPredicateSortedByDate:predicate
                                        completionQueue:dispatch_get_main_queue()
                                        completionBlock:^(NSArray *array)
        {
            weakSelf.chatsBadge.value = array.count ? [NSString stringWithFormat:@"%lu", (unsigned long)array.count] : nil;
        }];
    }
}

- (void)configureLoggingStuff
{
    // your log statements will be sent to the Console.app and the Xcode console (just like a normal NSLog)
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    [[DDTTYLogger sharedInstance] setLogFormatter:[CustomLogFormatter new]];

    DDLogInfo(@"\n\n\n\t\t\t\t\t\t***** Application started *****\n\n\n");
    DDLogInfo(@"Device:\n\tname = %@\n\tmodel = %@\n\tsystemVersion = %@\n\n",
            [UIDevice currentDevice].name,
            [UIDevice currentDevice].model,
            [UIDevice currentDevice].systemVersion);
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

    DDLogInfo(@"AppDelegate: starting background task...");
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        DDLogInfo(@"AppDelegate: starting background task... time is up, stopping it");

        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }];
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
