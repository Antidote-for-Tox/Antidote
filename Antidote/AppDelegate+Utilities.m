//
//  AppDelegate+Utilities.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 01.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "AppDelegate+Utilities.h"
#import "FriendsViewController.h"
#import "ChatViewController.h"
#import "ProfilesListViewController.h"

@implementation AppDelegate (Utilities)

#pragma mark -  Public

- (UIViewController *)visibleViewController
{
    UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;

    UINavigationController *navCon = (UINavigationController *)[tabBar selectedViewController];

    return [navCon topViewController];
}

- (void)switchToChatsTabAndShowChatViewControllerWithChat:(OCTChat *)chat
{
    UINavigationController *navCon = [self switchToIndexAndGetNavigation:AppDelegateTabIndexChats];

    ChatViewController *chatVC = nil;
    NSUInteger index = [self findViewControllerWithClass:[ChatViewController class]
                                            inNavigation:navCon
                                        resultController:&chatVC
                                             searchBlock:^BOOL (ChatViewController *cvc)
    {
        return [cvc.chat.uniqueIdentifier isEqualToString:chat.uniqueIdentifier];
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

    if (navCon.viewControllers.count > 1) {
        [navCon popToRootViewControllerAnimated:YES];
    }

    FriendsViewController *friendsVC = (FriendsViewController *)[navCon topViewController];

    [friendsVC switchToTab:FriendsViewControllerTabRequests];
}

- (void)switchToSettingsTabAndShowProfiles
{
    UINavigationController *navCon = [self switchToIndexAndGetNavigation:AppDelegateTabIndexSettings];
    UIViewController *top = [navCon topViewController];

    BOOL animated = ! [top isKindOfClass:[ProfilesListViewController class]];

    if (navCon.viewControllers.count > 1) {
        [navCon popToRootViewControllerAnimated:NO];
    }

    [navCon pushViewController:[ProfilesListViewController new] animated:animated];
}

#pragma mark -  Private

- (UINavigationController *)switchToIndexAndGetNavigation:(AppDelegateTabIndex)index
{
    UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;
    if (tabBar.selectedIndex != index) {
        tabBar.selectedIndex = index;
    }

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
