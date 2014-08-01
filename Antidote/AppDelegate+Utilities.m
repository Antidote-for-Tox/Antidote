//
//  AppDelegate+Utilities.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 01.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "AppDelegate+Utilities.h"
#import "ChatViewController.h"

static const NSUInteger kChatsIndex = 0;

@implementation AppDelegate (Utilities)

- (void)switchToChatsTabAndShowChatViewControllerWithChat:(CDChat *)chat
{
    UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;
    tabBar.selectedIndex = kChatsIndex;

    UINavigationController *navCon = (UINavigationController *)[tabBar selectedViewController];

    NSUInteger index = NSNotFound;
    ChatViewController *chatVC = nil;

    for (NSUInteger i = 0; i < navCon.viewControllers.count; i++) {
        UIViewController *vc = navCon.viewControllers[i];

        if (! [vc isKindOfClass:[ChatViewController class]]) {
            continue;
        }

        ChatViewController *cvc = (ChatViewController *)vc;

        NSManagedObjectID *id1 = chat.objectID;
        NSManagedObjectID *id2 = cvc.chat.objectID;

        if (id1 && id2 && [id1 isEqual:id2]) {
            index = i;
            chatVC = cvc;
            break;
        }
    }

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

@end
