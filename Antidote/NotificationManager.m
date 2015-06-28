//
//  NotificationManager.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 27.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <BlocksKit/NSMutableArray+BlocksKit.h>
#import <BlocksKit/NSTimer+BlocksKit.h>
#import <Masonry/Masonry.h>

#import "NotificationManager.h"
#import "NotificationObject.h"
#import "NotificationView.h"
#import "WindowPassingGestures.h"
#import "ViewPassingGestures.h"
#import "AppearanceManager.h"
#import "AppDelegate.h"
#import "NotificationViewController.h"

static const NSTimeInterval kAnimationDuration = 0.3;
static const NSTimeInterval kNotificationVisibleInterval = 3.0;

static const CGFloat kConnectingViewHeight = 30.0;

@interface NotificationManager () <NotificationViewControllerDelegate>

@property (strong, nonatomic) WindowPassingGestures *window;
@property (strong, nonatomic) UIView *notificationContentView;

@property (strong, nonatomic) NSMutableArray *notificationQueue;
@property (assign, nonatomic) BOOL areNotificationsActive;

@property (strong, nonatomic) UIView *connectingContentView;
@property (strong, nonatomic) UIView *connectingView;
@property (strong, nonatomic) MASConstraint *connectingContentViewTopConstraint;
@property (strong, nonatomic) MASConstraint *connectingViewTopConstraint;
@property (assign, nonatomic) BOOL isConnectingViewActive;

@end

@implementation NotificationManager

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    [self performSelectorOnMainThread:@selector(createWindow) withObject:nil waitUntilDone:YES];
    [self createNotificationView];
    [self createConnectingView];

    _notificationQueue = [NSMutableArray new];
    _areNotificationsActive = NO;

    return self;
}

#pragma mark -  Public

- (void)addNotificationToQueue:(NotificationObject *)notification
{
    NSParameterAssert(notification);

    @synchronized(self.notificationQueue) {
        [self.notificationQueue addObject:[notification copy]];

        if (self.areNotificationsActive) {
            return;
        }
        self.areNotificationsActive = YES;
        self.notificationContentView.hidden = NO;

        [self performSelectorOnMainThread:@selector(dequeueAndShowNextObject) withObject:nil waitUntilDone:NO];
    }
}

- (void)removeNotificationsFromQueueWithGroupIdentifier:(NSString *)groupIdentifier
{
    NSParameterAssert(groupIdentifier);

    @synchronized(self.notificationQueue) {
        [self.notificationQueue bk_performReject:^BOOL (NotificationObject *object) {
            return [object.groupIdentifier isEqualToString:groupIdentifier];
        }];
    }
}

- (void)showConnectingView
{
    @synchronized(self.connectingContentView) {
        self.isConnectingViewActive = YES;

        self.connectingViewTopConstraint.equalTo(-kConnectingViewHeight);
        [self.connectingContentView layoutIfNeeded];

        self.connectingContentView.hidden = NO;

        self.connectingViewTopConstraint.equalTo(0);
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [self.connectingContentView layoutIfNeeded];
        }];
    }
}

- (void)hideConnectingView
{
    @synchronized(self.connectingContentView) {
        self.isConnectingViewActive = NO;

        self.connectingViewTopConstraint.equalTo(0);
        [self.connectingContentView layoutIfNeeded];

        self.connectingViewTopConstraint.equalTo(-kConnectingViewHeight);
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [self.connectingContentView layoutIfNeeded];
        } completion:^(BOOL f) {
            if (! self.isConnectingViewActive) {
                self.connectingContentView.hidden = YES;
            }
        }];
    }
}

#pragma mark -  NotificationViewControllerDelegate

- (void)viewWillLayoutSubviews
{
    self.connectingContentViewTopConstraint.equalTo([self connectionViewTop]);
    [self.window.rootViewController.view layoutIfNeeded];
}

#pragma mark -  Private

- (void)createWindow
{
    self.window = [[WindowPassingGestures alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.windowLevel = UIWindowLevelStatusBar + 1;
    self.window.backgroundColor = [UIColor clearColor];

    if (self.window.hidden) {
        [self.window makeKeyAndVisible];
    }

    NotificationViewController *controller = [NotificationViewController new];
    controller.delegate = self;
    controller.view = [ViewPassingGestures new];
    controller.view.backgroundColor = [UIColor clearColor];
    self.window.rootViewController = controller;
}

- (void)createNotificationView
{
    self.notificationContentView = [UIView new];
    self.notificationContentView.backgroundColor = [UIColor clearColor];
    self.notificationContentView.clipsToBounds = YES;
    self.notificationContentView.hidden = YES;

    [self.window.rootViewController.view addSubview:self.notificationContentView];

    [self.notificationContentView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(0);
        make.height.equalTo(kNotificationViewHeight);
    }];
}

- (void)createConnectingView
{
    {
        self.connectingContentView = [UIView new];
        self.connectingContentView.backgroundColor = [UIColor clearColor];
        self.connectingContentView.clipsToBounds = YES;
        self.connectingContentView.hidden = YES;

        [self.window.rootViewController.view addSubview:self.connectingContentView];

        [self.connectingContentView makeConstraints:^(MASConstraintMaker *make) {
            self.connectingContentViewTopConstraint = make.top.equalTo([self connectionViewTop]);
            make.left.right.equalTo(0);
            make.height.equalTo(kConnectingViewHeight);
        }];
    }

    {
        self.connectingView = [UIView new];
        self.connectingView.backgroundColor = [[AppContext sharedContext].appearance textMainColor];
        [self.connectingContentView addSubview:self.connectingView];

        [self.connectingView makeConstraints:^(MASConstraintMaker *make) {
            self.connectingViewTopConstraint = make.top.equalTo(0);
            make.left.right.equalTo(0);
            make.height.equalTo(kConnectingViewHeight);
        }];
    }

    {
        UIView *container = [UIView new];
        container.backgroundColor = [UIColor clearColor];
        [self.connectingView addSubview:container];

        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [spinner startAnimating];
        [container addSubview:spinner];

        UILabel *label = [UILabel new];
        label.text = NSLocalizedString(@"Connecting...", @"NotificationManager");
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [[AppContext sharedContext].appearance fontHelveticaNeueLightWithSize:16.0];
        [container addSubview:label];

        [container makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.connectingView);
            make.centerY.equalTo(self.connectingView);
        }];

        [spinner makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.centerY.equalTo(container);
        }];

        [label makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(spinner.right).offset(10.0);
            make.right.equalTo(container);
            make.centerY.equalTo(container);
        }];
    }
}

- (void)dequeueAndShowNextObject
{
    NotificationObject *object;

    @synchronized(self.notificationQueue) {
        object = [self.notificationQueue firstObject];

        if (! object) {
            self.areNotificationsActive = NO;
            return;
        }

        [self.notificationQueue removeObjectAtIndex:0];
    }

    NotificationView *view = [[NotificationView alloc] initWithObject:object];
    [self.notificationContentView addSubview:view];

    __weak NotificationManager *weakSelf = self;

    [self showNotificationViewAnimated:view completion:^(MASConstraint *topConstraint) {
        void (^hideNotification)() = ^() {
            [weakSelf dequeueAndShowNextObject];

            [weakSelf hideNotificationViewAnimated:view topConstraint:topConstraint completion:^{
                [view removeFromSuperview];

                if (weakSelf.notificationContentView.subviews.count == 0) {
                    weakSelf.notificationContentView.hidden = YES;
                }
            }];
        };

        NSTimer *timer = [NSTimer bk_scheduledTimerWithTimeInterval:kNotificationVisibleInterval block:^(NSTimer *timer) {
            hideNotification();
        } repeats:NO];

        view.tapHandler = ^{
            if (object.tapHandler) {
                object.tapHandler(object);
            }

            [timer invalidate];
            hideNotification();
        };
    }];
}

- (void)showNotificationViewAnimated:(NotificationView *)view completion:(void (^)(MASConstraint *topConstraint))completion
{
    __block MASConstraint *topConstraint;

    [view makeConstraints:^(MASConstraintMaker *make) {
        topConstraint = make.top.equalTo(-kNotificationViewHeight);
        make.height.equalTo(kNotificationViewHeight);
        make.left.right.equalTo(0);
    }];

    [self.notificationContentView layoutIfNeeded];

    topConstraint.equalTo(0);
    [UIView animateWithDuration:kAnimationDuration animations:^{
        [self.notificationContentView layoutIfNeeded];
    } completion:^(BOOL f) {
        if (completion) {
            completion(topConstraint);
        }
    }];
}

- (void)hideNotificationViewAnimated:(NotificationView *)view
                       topConstraint:(MASConstraint *)topConstraint
                          completion:(void (^)())completion
{
    [self.notificationContentView layoutIfNeeded];

    topConstraint.equalTo(kNotificationViewHeight);
    [UIView animateWithDuration:kAnimationDuration animations:^{
        [self.notificationContentView layoutIfNeeded];

    } completion:^(BOOL f) {
        [view removeFromSuperview];

        if (completion) {
            completion();
        }
    }];
}

- (CGFloat)connectionViewTop
{
    CGFloat top = [UIApplication sharedApplication].statusBarFrame.size.height;

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *controller = delegate.window.rootViewController;

    if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBar = (UITabBarController *)controller;
        controller = tabBar.selectedViewController;

        if ([controller isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigation = (UINavigationController *)controller;
            top += navigation.navigationBar.frame.size.height;
        }
    }

    return top;
}

@end
