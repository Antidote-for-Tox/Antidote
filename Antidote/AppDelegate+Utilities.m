//
//  AppDelegate+Utilities.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 01.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "AppDelegate+Utilities.h"
#import "ChatViewController.h"
#import "FriendRequestsViewController.h"


@implementation AppDelegate (Utilities)

#pragma mark -  Public

- (UIViewController *)visibleViewController
{
    UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;

    UINavigationController *navCon = (UINavigationController *)[tabBar selectedViewController];

    return [navCon topViewController];
}

- (void)switchToChatsTabAndShowChatViewControllerWithChat:(CDChat *)chat
{
    UINavigationController *navCon = [self switchToIndexAndGetNavigation:AppDelegateTabIndexChats];

    ChatViewController *chatVC = nil;
    NSUInteger index = [self findViewControllerWithClass:[ChatViewController class]
                                            inNavigation:navCon
                                        resultController:&chatVC
                                             searchBlock:^BOOL (ChatViewController *cvc)
    {
        NSManagedObjectID *id1 = chat.objectID;
        NSManagedObjectID *id2 = cvc.chat.objectID;

        if (id1 && id2 && [id1 isEqual:id2]) {
            return YES;
        }
        return NO;
    }];

    if (index != NSNotFound) {
        if (index == navCon.viewControllers.count - 1) {
            // nothing to do here, controller is already visible
            return;
        }

        [navCon popToViewController:chatVC animated:NO];
        return;
    }

    // no chatVC found, creating and pushing it
    chatVC = [[ChatViewController alloc] initWithChat:chat];

    [navCon popToRootViewControllerAnimated:NO];
    [navCon pushViewController:chatVC animated:NO];
}

- (void)switchToFriendsTabAndShowFriendRequests
{
    UINavigationController *navCon = [self switchToIndexAndGetNavigation:AppDelegateTabIndexFriends];

    FriendRequestsViewController *friendRequestVC = nil;
    NSUInteger index = [self findViewControllerWithClass:[FriendRequestsViewController class]
                                            inNavigation:navCon
                                        resultController:&friendRequestVC
                                             searchBlock:^BOOL (UIViewController *v) { return YES; }];

    if (index != NSNotFound) {
        if (index == navCon.viewControllers.count - 1) {
            // nothing to do here, controller is already visible
            return;
        }

        [navCon popToViewController:friendRequestVC animated:NO];
        return;
    }

    // no controller found, creating and pushing it
    friendRequestVC = [FriendRequestsViewController new];

    [navCon popToRootViewControllerAnimated:NO];
    [navCon pushViewController:friendRequestVC animated:NO];
}

#pragma mark -  Private

- (UINavigationController *)switchToIndexAndGetNavigation:(AppDelegateTabIndex)index
{
    UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;
    tabBar.selectedIndex = index;

    return (UINavigationController *)[tabBar selectedViewController];
}

- (NSUInteger)findViewControllerWithClass:(Class)class
                             inNavigation:(UINavigationController *)navCon
                         resultController:(UIViewController **)resultController
                              searchBlock:(BOOL (^)(id viewController))searchBlock
{
    if (! searchBlock) {
        return NSNotFound;
    }

    for (NSUInteger index = 0; index < navCon.viewControllers.count; index++) {
        UIViewController *vc = navCon.viewControllers[index];

        if (! [vc isKindOfClass:class]) {
            continue;
        }

        if (searchBlock(vc)) {
            if (resultController) {
                *resultController = vc;
            }

            return index;
        }
    }

    return NSNotFound;
}

@end
