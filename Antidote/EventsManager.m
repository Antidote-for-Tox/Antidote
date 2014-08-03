//
//  EventsManager.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 03.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "EventsManager.h"
#import "CDMessage.h"
#import "CDChat.h"
#import "CDUser.h"
#import "AppDelegate+Utilities.h"
#import "ChatViewController.h"
#import "ToxManager.h"
#import "NSTimer+BlocksKit.h"
#import "UIControl+BlocksKit.h"
#import "UIColor+Utilities.h"
#import "UIView+Utilities.h"

@interface EventsManager()

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSMutableArray *queue;

@property (assign, nonatomic) BOOL isActive;

@end

@implementation EventsManager

#pragma mark -  Lifecycle

- (id)init
{
    return nil;
}

- (id)initPrivate
{
    if (self = [super init]) {
        [self performSelectorOnMainThread:@selector(createWindow) withObject:nil waitUntilDone:YES];

        _queue = [NSMutableArray new];
        _isActive = NO;
    }

    return self;
}

- (void)createWindow
{
    _window = [[UIWindow alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    _window.windowLevel = UIWindowLevelStatusBar + 1;
    _window.backgroundColor = [UIColor clearColor];
}

+ (instancetype)sharedInstance
{
    static EventsManager *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[EventsManager alloc] initPrivate];
    });

    return instance;
}

#pragma mark -  Public

- (void)addObject:(EventObject *)object
{
    [self performSelectorOnMainThread:@selector(addObjectOnMainThread:) withObject:object waitUntilDone:NO];
}

#pragma mark -  Private

- (void)addObjectOnMainThread:(EventObject *)object
{
    if (! [self shouldShowAlertWindowFor:object]) {
        return;
    }

    [self queueObject:object];

    @synchronized(self) {
        if (self.isActive) {
            return;
        }
        self.isActive = YES;
    }

    [self dequeueAndShowNextObject];
}

- (BOOL)shouldShowAlertWindowFor:(EventObject *)object
{
    if (object.type == EventObjectTypeChatMessage) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UIViewController *visibleVC = [delegate visibleViewController];

        if (! [visibleVC isKindOfClass:[ChatViewController class]]) {
            return YES;
        }

        ChatViewController *chatVC = (ChatViewController *)visibleVC;
        CDMessage *message = object.object;

        if (message.chat && [chatVC.chat isEqual:message.chat]) {
            // Chat is already visible, don't show alert window
            return NO;
        }
    }

    return YES;
}

- (void)queueObject:(EventObject *)object
{
    @synchronized(self) {
        [self.queue addObject:object];
    }
}

- (void)dequeueAndShowNextObject
{
    EventObject *object = nil;

    @synchronized(self) {
        object = [self.queue firstObject];

        if (! object) {
            self.isActive = NO;
            return;
        }

        [self.queue removeObjectAtIndex:0];
    }

    if (! [self shouldShowAlertWindowFor:object]) {
        [self dequeueAndShowNextObject];
        return;
    }

    if (self.window.hidden) {
        [self.window makeKeyAndVisible];
    }

    [self showEventViewWith:object];
}

- (void)showEventViewWith:(EventObject *)object
{
    __weak EventsManager *weakSelf = self;

    __block BOOL isClosed = NO;
    NSObject *syncObject = [NSObject new];

    void (^closeBlock)(UIView *theActiveView) = ^(UIView *theActiveView) {
        @synchronized(syncObject) {
            if (isClosed) {
                return;
            }
            isClosed = YES;
        }

        [UIView animateWithDuration:0.3 animations:^{
            theActiveView.alpha = 0.0;

            [weakSelf dequeueAndShowNextObject];

        } completion:^(BOOL finished) {
            [theActiveView removeFromSuperview];

            if (! weakSelf.isActive) {
                weakSelf.window.hidden = YES;
            }
        }];
    };

    NSString *text = [self textForObject:object];

    UIView *activeView = [self eventViewWithText:text image:object.image tapHandler:^(UIView *theActiveView) {
        [weakSelf performActionForObject:object];

        closeBlock(theActiveView);
    }];

    const CGRect originalFrame = activeView.frame;

    CGRect frame = originalFrame;
    frame.origin.y = - frame.size.height;
    activeView.frame = frame;

    [UIView animateWithDuration:0.3 animations:^{
        activeView.frame = originalFrame;
    }];

    [NSTimer bk_scheduledTimerWithTimeInterval:4.0 block:^(NSTimer *timer) {
        closeBlock(activeView);

    } repeats:NO];
}

- (UIView *)eventViewWithText:(NSString *)text
                        image:(UIImage *)image
                   tapHandler:(void (^)(UIView *view))tapHandler
{
    UIView *view = [[UIView alloc] initWithFrame:self.window.bounds];
    view.clipsToBounds = YES;
    view.backgroundColor = [UIColor uColorWithRed:65 green:56 blue:57 alpha:0.9];
    [self.window addSubview:view];

    UIImageView *imageView;
    if (image) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 40.0, 40.0)];
        imageView.image = image;
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = 3.0;

        [view addSubview:imageView];
    }

    {
        CGRect frame = CGRectZero;
        frame.size.width = view.frame.size.width - frame.origin.x;
        frame.size.height = 40.0;
        frame.origin.x = 10.0;
        frame.origin.y = (view.frame.size.height - frame.size.height);

        if (imageView) {
            CGFloat delta = CGRectGetMaxX(imageView.frame);

            frame.origin.x += delta;
            frame.size.width -= delta;
        }

        UILabel *label = [view addLabelWithTextColor:[UIColor whiteColor] bgColor:[UIColor clearColor]];
        label.frame = frame;
        label.text = text;
    }

    {
        UIButton *button = [[UIButton alloc] initWithFrame:view.bounds];
        button.backgroundColor = [UIColor clearColor];

        [button bk_addEventHandler:^(id sender) {
            if (tapHandler) {
                tapHandler(view);
            }

        } forControlEvents:UIControlEventTouchUpInside];

        [view addSubview:button];
    }

    return view;
}

- (NSString *)textForObject:(EventObject *)object
{
    NSString *text;

    if (object.type == EventObjectTypeChatMessage) {
        CDMessage *message = object.object;
        ToxFriend *friend = [[ToxManager sharedInstance].friendsContainer friendWithClientId:message.user.clientId];

        NSString *name = friend.associatedName ?: friend.clientId;
        if (name.length > 15) {
            name = [name substringToIndex:15];
        }

        text = [NSString stringWithFormat:@"%@: %@", name, message.text];
    }

    return text;
}

- (void)performActionForObject:(EventObject *)object
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    if (object.type == EventObjectTypeChatMessage) {
        CDMessage *message = object.object;

        [delegate switchToChatsTabAndShowChatViewControllerWithChat:message.chat];
    }
}

@end
