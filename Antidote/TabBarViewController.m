//
//  TabBarViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 09.07.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "TabBarViewController.h"
#import "TabBarBadgeItem.h"
#import "TabBarProfileItem.h"
#import "FriendsViewController.h"
#import "AllChatsViewController.h"
#import "SettingsViewController.h"
#import "ProfileViewController.h"
#import "AppearanceManager.h"

@interface TabBarViewController () <UITabBarControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIView *customTabBarView;

@property (nonatomic, strong) MASConstraint *customTabBarViewVisibleConstraint;
@property (nonatomic, strong) MASConstraint *customTabBarViewHiddenConstraint;

@property (strong, nonatomic) NSArray *items;

@end

@implementation TabBarViewController

#pragma mark -  Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;

    [self createViewControllers];

    [self createCustomTabBarView];
    [self createItems];

    [self installConstraints];

    [self updateSelectedItems];
}

#pragma mark -  Properties

- (void)setConnectionStatus:(StatusCircleStatus)status
{
    TabBarProfileItem *profileItem = self.items[TabBarViewControllerIndexProfile];
    profileItem.status = status;
}

- (StatusCircleStatus)connectionStatus
{
    TabBarProfileItem *profileItem = self.items[TabBarViewControllerIndexProfile];
    return profileItem.status;
}

#pragma mark -  Public

- (void)setBadge:(NSString *)string atIndex:(TabBarViewControllerIndex)index
{
    TabBarBadgeItem *item = self.items[index];

    if (! [item isKindOfClass:[TabBarBadgeItem class]]) {
        return;
    }

    item.badgeText = string;
}

- (UINavigationController *)navigationControllerForIndex:(TabBarViewControllerIndex)index
{
    UIViewController *controller = self.viewControllers[index];

    if ([controller isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)controller;
    }

    return nil;
}

#pragma mark -  UITabBarControllerDelegate

- (void)setSelectedIndex:(NSUInteger)index
{
    NSUInteger previousIndex = self.selectedIndex;

    [super setSelectedIndex:index];

    UINavigationController *navCon = [self navigationControllerForIndex:index];
    navCon.delegate = self;

    if (previousIndex == index) {
        [navCon popToRootViewControllerAnimated:YES];
    }

    [self updateSelectedItems];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)controller
{
    if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navCon = (UINavigationController *)controller;
        navCon.delegate = self;
    }
}

#pragma mark -  UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    self.tabBar.hidden = YES;

    if (viewController.hidesBottomBarWhenPushed) {
        [self.customTabBarViewVisibleConstraint deactivate];
        [self.customTabBarViewHiddenConstraint activate];
    }
    else {
        [self.customTabBarViewVisibleConstraint activate];
        [self.customTabBarViewHiddenConstraint deactivate];
    }
}

#pragma mark -  Private

- (void)createViewControllers
{
    NSMutableArray *array = [NSMutableArray new];

    for (TabBarViewControllerIndex index = 0; index < __TabBarViewControllerCount; index++) {
        [array addObject:[self createControllerWithIndex:index]];
    }

    self.viewControllers = [array copy];
}

- (UINavigationController *)createControllerWithIndex:(TabBarViewControllerIndex)index
{
    UIViewController *controller;

    switch (index) {
        case TabBarViewControllerIndexFriends:
            controller = [FriendsViewController new];
            break;
        case TabBarViewControllerIndexChats:
            controller = [AllChatsViewController new];
            break;
        case TabBarViewControllerIndexSettings:
            controller = [SettingsViewController new];
            break;
        case TabBarViewControllerIndexProfile:
            controller = [ProfileViewController new];
            break;
        case __TabBarViewControllerCount:
            // nop
            break;
    }

    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:controller];
    navCon.navigationBar.tintColor = [[AppContext sharedContext].appearance textMainColor];
    ;

    return navCon;
}

- (void)createCustomTabBarView
{
    self.customTabBarView = [UIView new];
    self.customTabBarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.customTabBarView];

    UIView *line = [UIView new];
    line.backgroundColor = [UIColor lightGrayColor];
    [self.customTabBarView addSubview:line];

    [line makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.customTabBarView);
        make.height.equalTo(0.5);
    }];
}

- (void)createItems
{
    NSMutableArray *items = [NSMutableArray new];

    for (TabBarViewControllerIndex index = 0; index < __TabBarViewControllerCount; index++) {
        UIView<TabBarItemProtocol> *item = [self createItemWithIndex:index];

        [self.customTabBarView addSubview:item];
        [items addObject:item];
    }

    self.items = [items copy];
}

- (UIView<TabBarItemProtocol> *)createItemWithIndex:(TabBarViewControllerIndex)index
{
    UIView<TabBarItemProtocol> *item;

    if (index == TabBarViewControllerIndexProfile) {
        TabBarProfileItem *profileItem = [TabBarProfileItem new];
        item = profileItem;
    }
    else {
        NSString *imageName;
        switch (index) {
            case TabBarViewControllerIndexFriends:
                imageName = @"tab-bar-friends";
                break;
            case TabBarViewControllerIndexChats:
                imageName = @"tab-bar-chats";
                break;
            case TabBarViewControllerIndexSettings:
                imageName = @"tab-bar-settings";
                break;
            case TabBarViewControllerIndexProfile:
            case __TabBarViewControllerCount:
                // nop
                break;
        }

        TabBarBadgeItem *badgeItem = [TabBarBadgeItem new];

        badgeItem.text = [self.viewControllers[index] title];
        badgeItem.image = [UIImage imageNamed:imageName];

        item = badgeItem;
    }

    item.didTapOnItem = ^(UIView<TabBarItemProtocol> *i) {
        self.selectedIndex = index;
    };

    return item;
}

- (void)installConstraints
{
    [self.customTabBarView makeConstraints:^(MASConstraintMaker *make) {
        self.customTabBarViewVisibleConstraint = make.bottom.equalTo(self.view.bottom);
        self.customTabBarViewHiddenConstraint = make.top.equalTo(self.view.bottom);
        make.left.right.equalTo(self.view);
        make.height.equalTo(self.tabBar.frame.size.height);
    }];

    [self.customTabBarViewHiddenConstraint deactivate];

    TabBarBadgeItem *previous = nil;

    for (TabBarBadgeItem *item in self.items) {
        [item makeConstraints:^(MASConstraintMaker *make) {
            if (previous) {
                make.left.equalTo(previous.right);
                make.width.equalTo(previous);
            }
            else {
                make.left.equalTo(self.customTabBarView);
            }

            make.top.bottom.equalTo(self.customTabBarView);
        }];

        previous = item;
    }
    [previous makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.customTabBarView);
    }];
}

- (UIView *)findCommonSuperviewForView:(UIView *)first andView:(UIView *)second
{
    NSArray *firstHierarchy = [self hierarchyForView:first accumulator:@[]];
    NSArray *secondHierarchy = [self hierarchyForView:second accumulator:@[]];

    return [firstHierarchy firstObjectCommonWithArray:secondHierarchy];
}

- (NSArray *)hierarchyForView:(UIView *)view accumulator:(NSArray *)accumulator
{
    if (view) {
        return [self hierarchyForView:view.superview accumulator:[accumulator arrayByAddingObject:view]];
    }

    return accumulator;
}

- (void)updateSelectedItems
{
    for (NSUInteger index = 0; index < self.items.count; index++) {
        UIView<TabBarItemProtocol> *item = self.items[index];

        item.selected = (index == self.selectedIndex);
    }
}

@end
