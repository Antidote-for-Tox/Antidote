//
//  NotificationManager.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 27.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <BlocksKit/NSTimer+BlocksKit.h>
#import <Masonry/Masonry.h>

#import "NotificationManager.h"
#import "NotificationObject.h"
#import "NotificationView.h"
#import "WindowPassingGestures.h"
#import "ViewPassingGestures.h"

static const CGFloat kNotificationHeight = 40.0;
static const NSTimeInterval kAnimationDuration = 0.3;
static const NSTimeInterval kNotificationVisibleInterval = 3.0;

@interface NotificationManager ()

@property (strong, nonatomic) WindowPassingGestures *window;
@property (strong, nonatomic) UIView *notificationContentView;

@property (strong, nonatomic) NSMutableArray *queue;

@property (assign, nonatomic) BOOL isActive;

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

    _queue = [NSMutableArray new];
    _isActive = NO;

    return self;
}

#pragma mark -  Public

- (void)addNotificationToQueue:(NotificationObject *)notification
{
    @synchronized(self) {
        [self.queue addObject:notification];

        if (self.isActive) {
            return;
        }
        self.isActive = YES;
        self.notificationContentView.hidden = NO;

        [self performSelectorOnMainThread:@selector(dequeueAndShowNextObject) withObject:nil waitUntilDone:NO];
    }
}

- (void)showConnectingView
{}

- (void)hideConnectingView
{}

#pragma mark -  Private

- (void)createWindow
{
    self.window = [[WindowPassingGestures alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.windowLevel = UIWindowLevelStatusBar + 1;
    self.window.backgroundColor = [UIColor clearColor];

    if (self.window.hidden) {
        [self.window makeKeyAndVisible];
    }

    self.notificationContentView = [UIView new];
    self.notificationContentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.1];
    self.notificationContentView.clipsToBounds = YES;
    self.notificationContentView.hidden = YES;

    UIViewController *controller = [UIViewController new];
    controller.view = [ViewPassingGestures new];
    controller.view.backgroundColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.1];
    [controller.view addSubview:self.notificationContentView];
    self.window.rootViewController = controller;

    [self.notificationContentView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(0);
        make.height.equalTo(kNotificationHeight);
    }];
}

- (void)dequeueAndShowNextObject
{
    NotificationObject *object;

    @synchronized(self) {
        object = [self.queue firstObject];

        if (! object) {
            self.isActive = NO;
            return;
        }

        [self.queue removeObjectAtIndex:0];
    }

    NotificationView *view = [NotificationView new];
    [self.notificationContentView addSubview:view];

    __weak NotificationManager *weakSelf = self;

    [self showNotificationViewAnimated:view completion:^(MASConstraint *topConstraint) {
        [NSTimer bk_scheduledTimerWithTimeInterval:kNotificationVisibleInterval block:^(NSTimer *timer) {
            [weakSelf dequeueAndShowNextObject];

            [weakSelf hideNotificationViewAnimated:view topConstraint:topConstraint completion:^{
                [view removeFromSuperview];

                if (weakSelf.notificationContentView.subviews.count == 0) {
                    weakSelf.notificationContentView.hidden = YES;
                }
            }];
        } repeats:NO];
    }];
}

- (void)showNotificationViewAnimated:(NotificationView *)view completion:(void (^)(MASConstraint *topConstraint))completion
{
    __block MASConstraint *topConstraint;

    [view makeConstraints:^(MASConstraintMaker *make) {
        topConstraint = make.top.equalTo(-kNotificationHeight);
        make.height.equalTo(kNotificationHeight);
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

    topConstraint.equalTo(kNotificationHeight);
    [UIView animateWithDuration:kAnimationDuration animations:^{
        [self.notificationContentView layoutIfNeeded];

    } completion:^(BOOL f) {
        [view removeFromSuperview];

        if (completion) {
            completion();
        }
    }];
}

@end
