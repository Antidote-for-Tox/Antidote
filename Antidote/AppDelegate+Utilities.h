//
//  AppDelegate+Utilities.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 01.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "AppDelegate.h"
#import "OCTChat.h"

@interface AppDelegate (Utilities)

- (UIViewController *)visibleViewController;
- (void)switchToChatsTabAndShowChatViewControllerWithChat:(OCTChat *)chat;
- (void)switchToFriendsTabAndShowFriendRequests;

@end
