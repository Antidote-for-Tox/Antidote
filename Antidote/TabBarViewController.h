//
//  TabBarViewController.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 09.07.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TabBarViewControllerIndex) {
    TabBarViewControllerIndexFriends = 0,
    TabBarViewControllerIndexChats,
    TabBarViewControllerIndexSettings,
    TabBarViewControllerIndexProfile,
    __TabBarViewControllerCount,
};

@interface TabBarViewController : UITabBarController

@end
