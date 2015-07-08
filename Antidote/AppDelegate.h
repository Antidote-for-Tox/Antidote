//
//  AppDelegate.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 18.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AppDelegateTabIndex) {
    AppDelegateTabIndexFriends = 0,
    AppDelegateTabIndexChats,
    AppDelegateTabIndexSettings,
    AppDelegateTabIndexProfile,
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)recreateControllersAndShow:(AppDelegateTabIndex)tabIndex;
- (void)recreateControllersAndShow:(AppDelegateTabIndex)tabIndex
                         withBlock:(void (^)(UINavigationController *topNavigation))block;

- (void)updateBadgeForTab:(AppDelegateTabIndex)tabIndex;

- (NSArray *)getLogFilesPaths;

@end
