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
    NSParameterAssert(notification);

    @synchronized(self.queue) {
        [self.queue addObject:[notification copy]];

        if (self.isActive) {
            return;
        }
        self.isActive = YES;
        self.notificationContentView.hidden = NO;

        [self performSelectorOnMainThread:@selector(dequeueAndShowNextObject) withObject:nil waitUntilDone:NO];
    }
}

- (void)removeNotificationsFromQueueWithGroupIdentifier:(NSString *)groupIdentifier
{
    NSParameterAssert(groupIdentifier);

    @synchronized(self.queue) {
        [self.queue bk_performReject:^BOOL (NotificationObject *object) {
            return [object.groupIdentifier isEqualToString:groupIdentifier];
        }];
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
    self.notificationContentView.backgroundColor = [UIColor clearColor];
    self.notificationContentView.clipsToBounds = YES;
    self.notificationContentView.hidden = YES;

    UIViewController *controller = [UIViewController new];
    controller.view = [ViewPassingGestures new];
    controller.view.backgroundColor = [UIColor clearColor];
    [controller.view addSubview:self.notificationContentView];
    self.window.rootViewController = controller;

    [self.notificationContentView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(0);
        make.height.equalTo(kNotificationViewHeight);
    }];
}

- (void)dequeueAndShowNextObject
{
    NotificationObject *object;

    @synchronized(self.queue) {
        object = [self.queue firstObject];

        if (! object) {
            self.isActive = NO;
            return;
        }

        [self.queue removeObjectAtIndex:0];
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

@end
