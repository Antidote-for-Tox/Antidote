//
//  TabBarViewController.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 09.07.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatusCircleView.h"

typedef NS_ENUM(NSUInteger, TabBarViewControllerIndex) {
    TabBarViewControllerIndexFriends = 0,
    TabBarViewControllerIndexChats,
    TabBarViewControllerIndexSettings,
    TabBarViewControllerIndexProfile,
    __TabBarViewControllerCount,
};

/**
 * Controller representing TabBar. Is responsible for creating all controllers.
 */
@interface TabBarViewController : UITabBarController

@property (assign, nonatomic) StatusCircleStatus connectionStatus;

@end
