//
//  FriendsViewController.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FriendsViewControllerTab) {
    FriendsViewControllerTabFriends = 0,
    FriendsViewControllerTabRequests,
};

@interface FriendsViewController : UIViewController

- (void)switchToTab:(FriendsViewControllerTab)tab;

@end
