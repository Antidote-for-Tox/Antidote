//
//  AppDelegate.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 18.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AppDelegateTabIndex) {
    AppDelegateTabIndexChats = 0,
    AppDelegateTabIndexFriends,
    AppDelegateTabIndexSettings,
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)recreateControllersAndShow:(AppDelegateTabIndex)tabIndex;

@end
