//
//  ChatViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ChatViewController.h"
#import "UIViewController+Utilities.h"
#import "ChatIncomingCell.h"
#import "ChatOutgoingCell.h"
#import "ChatInputView.h"
#import "CoreDataManager+Message.h"
#import "CDUser.h"
#import "ToxManager.h"
#import "UIView+Utilities.h"
#import "Helper.h"
#import "TimeFormatter.h"
#import "AppDelegate.h"

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, ChatInputViewDelegate,
    UIGestureRecognizerDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) ChatInputView *inputView;

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) CDChat *chat;
@property (strong, nonatomic) ToxFriend *friend;

@property (strong, nonatomic) NSString *myClientId;

@property (assign, nonatomic) BOOL didLayousSubviewsForFirstTime;

@property (assign, nonatomic) CGFloat visibleKeyboardHeight;

@end

@implementation ChatViewController

#pragma mark -  Lifecycle

- (instancetype)initWithChat:(CDChat *)chat;
{
    self = [super init];

    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.visibleKeyboardHeight = 0.0;

        self.myClientId = [ToxManager sharedInstance].clientId;

        self.chat = chat;

        NSString *clientId = [[chat.users anyObject] clientId];
        self.friend = [[ToxManager sharedInstance].friendsContainer friendWithClientId:clientId];

        [self updateTitleView];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newMessageNotification:)
                                                     name:kCoreDataManagerNewMessageNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(friendUpdateNotification:)
                                                     name:kToxFriendsContainerUpdateSpecificFriendNotification
                                                   object:nil];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    [self loadWhiteView];

    [self createTableView];
    [self createRecognizers];
    [self createInputView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateLastReadDateAndChatsBadge];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.messages = [NSMutableArray arrayWithArray:[CoreDataManager messagesForChat:self.chat]];
    [self.tableView reloadData];

    [self updateIsTypingFooter];
    [self updateSendButtonEnabled];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if (! self.didLayousSubviewsForFirstTime) {
        self.didLayousSubviewsForFirstTime = YES;

        [self adjustSubviews];
        [self scrollToBottomAnimated:NO];
    }
}

#pragma mark -  Gestures

- (void)tableViewPanGesture:(UIPanGestureRecognizer *)panGR
{
    if (panGR.state == UIGestureRecognizerStateChanged) {
        const CGPoint translation = [panGR translationInView:self.tableView];
        const CGFloat minOriginX = -40.0;

        [panGR setTranslation:CGPointZero inView:self.tableView];

        for (UITableViewCell *cell in [self.tableView visibleCells]) {
            CGRect frame = cell.contentView.frame;
            frame.origin.x += translation.x;

            if (frame.origin.x <= minOriginX) {
                frame.origin.x = minOriginX;
            }
            if (frame.origin.x >= 0.0) {
                frame.origin.x = 0.0;
            }

            cell.contentView.frame = frame;
        }
    }
    else if (panGR.state == UIGestureRecognizerStateEnded ||
        panGR.state == UIGestureRecognizerStateCancelled)
    {
        self.view.userInteractionEnabled = NO;

        [UIView animateWithDuration:0.2 animations:^{
            for (UITableViewCell *cell in [self.tableView visibleCells]) {
                CGRect frame = cell.contentView.frame;
                frame.origin.x = 0.0;
                cell.contentView.frame = frame;
            }
        } completion:^(BOOL f) {
            self.view.userInteractionEnabled = YES;
        }];
    }
}

- (void)tableViewTapGesture:(UITapGestureRecognizer *)tapGR
{
    [self.inputView resignFirstResponder];
}

#pragma mark -  UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CDMessage *message = self.messages[indexPath.row];

    ChatBasicCell *cell;

    if ([self isOutgoingMessage:message]) {
        cell = [tableView dequeueReusableCellWithIdentifier:[ChatOutgoingCell reuseIdentifier]
                                               forIndexPath:indexPath];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:[ChatIncomingCell reuseIdentifier]
                                               forIndexPath:indexPath];
    }

    cell.message = message.text;

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.date];

    cell.fullDateString = [self showFullDateForMessage:message atIndexPath:indexPath] ?
        [[TimeFormatter sharedInstance] stringFromDate:date type:TimeFormatterTypeRelativeDateAndTime] : nil;

    cell.hiddenDateString = [[TimeFormatter sharedInstance] stringFromDate:date type:TimeFormatterTypeTime];

    [cell redraw];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark -  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CDMessage *message = self.messages[indexPath.row];

    NSString *fullDateString = [self showFullDateForMessage:message atIndexPath:indexPath] ? @"placeholder" : nil;

    if ([self isOutgoingMessage:message]) {
        return [ChatOutgoingCell heightWithMessage:message.text fullDateString:fullDateString];
    }
    else {
        return [ChatIncomingCell heightWithMessage:message.text fullDateString:fullDateString];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -  ChatInputViewDelegate

- (void)chatInputViewWantsToUpdateFrame:(ChatInputView *)view
{
    CGFloat maxHeight = self.tableView.frame.size.height - self.tableView.contentInset.top - self.visibleKeyboardHeight;
    maxHeight *= 2.0 / 3.0;

    CGRect frame = view.frame;
    frame.size.height = MIN(maxHeight, [view heightWithCurrentTextAndWidth:frame.size.width]);
    view.frame = frame;

    [self updateTableViewInsetAndInputViewWithDuration:0.3 curve:UIViewAnimationCurveEaseInOut];
}

- (void)chatInputView:(ChatInputView *)view sendButtonPressedWithText:(NSString *)text;
{
    [[ToxManager sharedInstance] sendMessage:text toChat:self.chat];

    [view setText:nil];
}

- (void)chatInputView:(ChatInputView *)view typingChangedTo:(BOOL)isTyping
{
    [[ToxManager sharedInstance] changeIsTypingInChat:self.chat to:isTyping];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *)gestureRecognizer;

        CGPoint translation = [panGR translationInView:self.tableView];

        // Check for horizontal gesture
        if (fabsf(translation.x) > fabsf(translation.y)) {
            return YES;
        }
    }

    return NO;
}

#pragma mark -  Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.visibleKeyboardHeight = keyboardRect.size.height;

    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] doubleValue];

    [self updateTableViewInsetAndInputViewWithDuration:duration curve:curve];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.visibleKeyboardHeight = 0.0;

    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] doubleValue];

    [self updateTableViewInsetAndInputViewWithDuration:duration curve:curve];
}

- (void)newMessageNotification:(NSNotification *)notification
{
    if (self.isViewLoaded && self.view.window) {
        // is visible
        [self updateLastReadDateAndChatsBadge];
    }

    CDMessage *message = notification.userInfo[kCoreDataManagerNewMessageKey];

    if (! [message.chat isEqual:self.chat]) {
        return;
    }

    NSIndexPath *lastMessagePath;

    if (self.messages.count) {
        lastMessagePath = [NSIndexPath indexPathForRow:self.messages.count-1 inSection:0];
    }

    [self.messages addObject:message];

    @synchronized(self.tableView) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:self.messages.count-1 inSection:0];

        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }

    // scroll to bottom only if last message was visible
    if (lastMessagePath) {
        CGRect rect = CGRectZero;
        rect.origin = self.tableView.contentOffset;
        rect.size = self.tableView.frame.size;
        rect.size.height -= self.tableView.contentInset.bottom;

        NSArray *visiblePathes = [self.tableView indexPathsForRowsInRect:rect];

        if ([visiblePathes containsObject:lastMessagePath]) {
            [self scrollToBottomAnimated:YES];
        }
    }
}

- (void)friendUpdateNotification:(NSNotification *)notification
{
    ToxFriend *updatedFriend = notification.userInfo[kToxFriendsContainerUpdateKeyFriend];

    if (! [self.friend isEqual:updatedFriend]) {
        return;
    }

    self.friend = updatedFriend;
    [self updateTitleView];
    [self updateIsTypingFooter];
    [self updateSendButtonEnabled];
}

#pragma mark -  Private

- (void)createTableView
{
    self.tableView = [UITableView new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.tableView registerClass:[ChatIncomingCell class] forCellReuseIdentifier:[ChatIncomingCell reuseIdentifier]];
    [self.tableView registerClass:[ChatOutgoingCell class] forCellReuseIdentifier:[ChatOutgoingCell reuseIdentifier]];

    [self.view addSubview:self.tableView];
}

- (void)createRecognizers
{
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(tableViewTapGesture:)];

    [self.tableView addGestureRecognizer:tapGR];

    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(tableViewPanGesture:)];
    panGR.delegate = self;
    [self.tableView addGestureRecognizer:panGR];
}

- (void)createInputView
{
    self.inputView = [ChatInputView new];
    self.inputView.delegate = self;
    [self.view addSubview:self.inputView];
}

- (void)adjustSubviews
{
    const CGFloat inputViewWidth = self.view.bounds.size.width;
    const CGFloat inputViewHeight = [self.inputView heightWithCurrentTextAndWidth:inputViewWidth];

    self.tableView.frame = self.view.bounds;

    {
        CGRect frame = CGRectZero;
        frame.size.width = inputViewWidth;
        frame.size.height = inputViewHeight;
        self.inputView.frame = frame;
    }

    [self updateTableViewInsetAndInputViewWithDuration:0.0 curve:0];
}

- (void)updateTitleView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];

    UILabel *label = [view addLabelWithTextColor:[UIColor blackColor] bgColor:[UIColor clearColor]];
    label.text = self.friend.associatedName;
    [label sizeToFit];

    StatusCircleView *statusView = [StatusCircleView new];
    statusView.status = [Helper toxFriendStatusToCircleStatus:self.friend.status];
    [statusView redraw];
    [view addSubview:statusView];

    const CGFloat height = MAX(label.frame.size.height, statusView.frame.size.height);

    CGRect frame = label.frame;
    frame.origin.y = (height - frame.size.height) / 2;
    label.frame = frame;

    frame = statusView.frame;
    frame.origin.x = label.frame.size.width + 10.0;
    frame.origin.y = (height - frame.size.height) / 2;
    statusView.frame = frame;

    frame = CGRectZero;
    frame.size.height = height;
    frame.size.width = CGRectGetMaxX(statusView.frame);
    view.frame = frame;

    self.navigationItem.titleView = view;
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    if (! self.messages.count) {
        return;
    }
    NSIndexPath *path = [NSIndexPath indexPathForRow:self.messages.count-1 inSection:0];

    // tableView animation may cause lags (in case if there will be too many messages). When using default UIView
    // animation, there's no lags for some reason
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
    }

    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];

    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)updateTableViewInsetAndInputViewWithDuration:(NSTimeInterval)duration curve:(UIViewAnimationCurve)curve
{
    if (duration) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:curve];
    }

    {
        // tableView

        const CGFloat old = self.tableView.contentInset.bottom;
        const CGFloat new = self.inputView.frame.size.height + self.visibleKeyboardHeight;

        UIEdgeInsets insets = self.tableView.contentInset;
        insets.bottom = new;
        self.tableView.contentInset = insets;
        self.tableView.scrollIndicatorInsets = insets;

        if (new > old) {
            CGPoint offset = self.tableView.contentOffset;

            const CGFloat visibleHeight = self.tableView.frame.size.height - insets.top - insets.bottom;
            if (self.tableView.contentSize.height < visibleHeight) {
                // don't change offset
                goto tableViewEnd;
            }

            offset.y += (new - old);

            if (offset.y < 0.0) {
                offset.y = 0.0;
            }

            [self.tableView setContentOffset:offset animated:NO];
        }

    }
    tableViewEnd:

    {
        // inputView

        CGRect frame = self.inputView.frame;
        frame.origin.y = self.tableView.frame.size.height - self.tableView.contentInset.bottom;
        self.inputView.frame = frame;
    }

    if (duration) {
        [UIView commitAnimations];
    }
}

- (void)updateIsTypingFooter
{
    if (self.friend.isTyping) {
        if (self.tableView.tableFooterView) {
            return;
        }

        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor lightGrayColor];
        label.font = [AppearanceManager fontHelveticaNeueWithSize:16.0];
        label.text = NSLocalizedString(@"typing...", @"Chat");
        label.textAlignment = NSTextAlignmentCenter;
        [label sizeToFit];

        self.tableView.tableFooterView = label;
        [self scrollToBottomAnimated:YES];
    }
    else {
        if (self.tableView.tableFooterView) {
            self.tableView.tableFooterView = nil;
        }
    }
}

- (void)updateSendButtonEnabled
{
    self.inputView.sendButtonEnabled = (self.friend.status != ToxFriendStatusOffline);
}

- (BOOL)isOutgoingMessage:(CDMessage *)message
{
    return [message.user.clientId isEqual:self.myClientId];
}

- (BOOL)showFullDateForMessage:(CDMessage *)message atIndexPath:(NSIndexPath *)path
{
    if (path.row == 0) {
        return YES;
    }

    CDMessage *previous = self.messages[path.row-1];

    NSDate *messageDate  = [NSDate dateWithTimeIntervalSince1970:message.date];
    NSDate *previousDate = [NSDate dateWithTimeIntervalSince1970:previous.date];

    if (! [[TimeFormatter sharedInstance] areSameDays:messageDate and:previousDate]) {
        return YES;
    }

    NSTimeInterval delta = message.date - previous.date;

    if (delta > 5 * 60 * 60) {
        return YES;
    }

    return NO;
}

- (void)updateLastReadDateAndChatsBadge
{
    NSDate *date = [NSDate date];

    [CoreDataManager editCDObjectWithBlock:^{
        self.chat.lastReadDate = [date timeIntervalSince1970];
    }];

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate updateBadgeForTab:AppDelegateTabIndexChats];
}

@end
