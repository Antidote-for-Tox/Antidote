//
//  AppDelegate.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 18.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#define MR_ENABLE_ACTIVE_RECORD_LOGGING 0

#import <MobileCoreServices/MobileCoreServices.h>

#import "AppDelegate.h"
#import "AppDelegate+Utilities.h"
#import "CustomLogFormatter.h"
#import "DDFileLogger.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "AllChatsViewController.h"
#import "FriendsViewController.h"
#import "SettingsViewController.h"
#import "BadgeWithText.h"
#import "UIAlertView+BlocksKit.h"
#import "EventsManager.h"

@interface AppDelegate()

@property (strong, nonatomic) DDFileLogger *fileLogger;

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

    // initialize context
    [AppContext sharedInstance];

    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"DataStore.sqlite"];
    [[UserInfoManager sharedInstance] createDefaultValuesIfNeeded];
    [[ProfileManager sharedInstance] configureCurrentProfileAndLoadTox];

    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        UIUserNotificationType types =
            UIUserNotificationTypeAlert |
            UIUserNotificationTypeBadge |
            UIUserNotificationTypeSound;

        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];

        [application registerUserNotificationSettings:settings];
    }

    [self recreateControllersAndShow:AppDelegateTabIndexChats];

    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey]) {
        UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];

        [[EventsManager sharedInstance] handleLocalNotification:notification];
    }

    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([url isFileURL]) {
        NSURLRequest *fileUrlRequest = [[NSURLRequest alloc] initWithURL:url
                                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                         timeoutInterval:.1];

        NSURLResponse *response = nil;
        [NSURLConnection sendSynchronousRequest:fileUrlRequest returningResponse:&response error:nil];

        NSString* mimeType = [response MIMEType];

        CFStringRef mimeTypeRef = (__bridge CFStringRef)mimeType;
        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeTypeRef, NULL);

        if (CFStringCompare(UTI, kUTTypeData, 0) == kCFCompareEqualTo) {
            [self handleIncomingFileAtUrl:url isDataFile:YES];
        }
        else {
            [self handleIncomingFileAtUrl:url isDataFile:NO];
        }
    }

    return YES;
}

- (void)recreateControllersAndShow:(AppDelegateTabIndex)tabIndex
{
    [self recreateControllersAndShow:tabIndex withBlock:nil];
}

- (void)recreateControllersAndShow:(AppDelegateTabIndex)tabIndex
                         withBlock:(void (^)(UINavigationController *topNavigation))block;
{
    UINavigationController *friends = [[UINavigationController alloc] initWithRootViewController:[FriendsViewController new]];
    UINavigationController *allChats = [[UINavigationController alloc] initWithRootViewController:[AllChatsViewController new]];
    UINavigationController *settings = [[UINavigationController alloc] initWithRootViewController:[SettingsViewController new]];

    UITabBarController *tabBar = [UITabBarController new];
    tabBar.viewControllers = @[friends, allChats, settings];

    friends.navigationBar.tintColor  =
    allChats.navigationBar.tintColor =
    settings.navigationBar.tintColor =
    tabBar.tabBar.tintColor          = [[AppContext sharedContext].appearance textMainColor];

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

    if (block) {
        block((UINavigationController *) tabBar.selectedViewController);
    }
}

- (BadgeWithText *)addBadgeAtIndex:(NSUInteger)index
{
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;

    CGRect frame = CGRectZero;
    frame.origin.x = index * (tabBarController.tabBar.frame.size.width / 3) +
        tabBarController.tabBar.frame.size.width / 6;
    frame.origin.y = 3.0;

    BadgeWithText *badge = [[BadgeWithText alloc] initWithFrame:frame];
    badge.backgroundColor = [[AppContext sharedContext].appearance statusBusyColor];
    [tabBarController.tabBar addSubview:badge];

    return badge;
}

- (void)updateBadgeForTab:(AppDelegateTabIndex)tabIndex
{
    __weak AppDelegate *weakSelf = self;

    void (^updateApplicationBadge)() = ^() {
        [UIApplication sharedApplication].applicationIconBadgeNumber =
            [self.friendsBadge.value integerValue] + [self.chatsBadge.value integerValue];
    };

    if (tabIndex == AppDelegateTabIndexFriends) {
        NSUInteger number = [[ToxManager sharedInstance].friendsContainer requestsCount];

        self.friendsBadge.value = number ? [NSString stringWithFormat:@"%lu", (unsigned long)number] : nil;
        updateApplicationBadge();
    }
    else if (tabIndex == AppDelegateTabIndexChats) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastMessage.date > lastReadDate"];

        [CoreDataManager currentProfileChatsWithPredicateSortedByDate:predicate
                                                      completionQueue:dispatch_get_main_queue()
                                                      completionBlock:^(NSArray *array)
        {
            weakSelf.chatsBadge.value = array.count ? [NSString stringWithFormat:@"%lu", (unsigned long)array.count] : nil;
            updateApplicationBadge();
        }];
    }
}

- (NSArray *)getLogFilesPaths
{
    return [self.fileLogger.logFileManager unsortedLogFilePaths];
}

- (void)configureLoggingStuff
{
    self.fileLogger = [DDFileLogger new];
    self.fileLogger.maximumFileSize = 1024 * 1024;
    self.fileLogger.rollingFrequency = 0.0;
    self.fileLogger.logFileManager.maximumNumberOfLogFiles = 2;

    [DDLog addLogger:self.fileLogger];

    // your log statements will be sent to the Console.app and the Xcode console (just like a normal NSLog)
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    CustomLogFormatter *formatter = [CustomLogFormatter new];

    [self.fileLogger setLogFormatter:formatter];
    [[DDASLLogger sharedInstance] setLogFormatter:formatter];
    [[DDTTYLogger sharedInstance] setLogFormatter:formatter];

    DDLogInfo(@"\n\n\n\t\t\t\t\t\t***** Application started *****\n\n\n");
    DDLogInfo(@"Device:\n\tname = %@\n\tmodel = %@\n\tsystemVersion = %@\n\n",
            [UIDevice currentDevice].name,
            [UIDevice currentDevice].model,
            [UIDevice currentDevice].systemVersion);
}

- (void)handleIncomingFileAtUrl:(NSURL *)url isDataFile:(BOOL)isDataFile
{
    void (^removeFile)() = ^() {
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    };

    if (isDataFile) {
        NSString *message = [NSString stringWithFormat:
            NSLocalizedString(@"Use \"%@\" file as tox save file?", @"Incoming file"),
            [url lastPathComponent]];

        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:nil message:message];

        [alert bk_addButtonWithTitle:NSLocalizedString(@"Yes", @"Incoming file") handler:^{
            NSString *title = NSLocalizedString(@"Enter profile name", @"Incoming file");

            UIAlertView *nameAlert = [UIAlertView bk_alertViewWithTitle:title];
            nameAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [nameAlert textFieldAtIndex:0].text = [url lastPathComponent];

            [nameAlert bk_addButtonWithTitle:NSLocalizedString(@"OK", @"Incoming file") handler:^{
                NSString *name = [nameAlert textFieldAtIndex:0].text;

                [[ProfileManager sharedInstance] addNewProfileWithName:name fromURL:url removeAfterAdding:YES];

                [self switchToSettingsTabAndShowProfiles];
            }];

            [nameAlert bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Incoming file") handler:removeFile];
            [nameAlert show];

        }];

        [alert bk_setCancelButtonWithTitle:NSLocalizedString(@"No", @"Incoming file") handler:removeFile];
        [alert show];
    }
    else {
        removeFile();
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[EventsManager sharedInstance] handleLocalNotification:notification];
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
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}

@end
