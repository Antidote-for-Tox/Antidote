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
#import "ChatTypingCell.h"
#import "ChatFileCell.h"
#import "ChatInputView.h"
#import "CoreDataManager+Message.h"
#import "CDUser.h"
#import "ToxManager.h"
#import "UIView+Utilities.h"
#import "Helper.h"
#import "TimeFormatter.h"
#import "AppDelegate.h"

typedef NS_ENUM(NSInteger, Section) {
    SectionMessages = 0,
    SectionTyping,
};

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate, ChatInputViewDelegate,
    UIGestureRecognizerDelegate, ChatFileCellDelegate, UIDocumentInteractionControllerDelegate,
    ToxManagerFileProgressDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) ChatInputView *inputView;

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) CDChat *chat;
@property (strong, nonatomic) ToxFriend *friend;

@property (assign, nonatomic) CGFloat visibleKeyboardHeight;

@property (assign, nonatomic) BOOL showTypingSection;

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

@end

@implementation ChatViewController

#pragma mark -  Lifecycle

- (instancetype)initWithChat:(CDChat *)chat;
{
    self = [super init];

    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.visibleKeyboardHeight = 0.0;

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
                                                 selector:@selector(messageUpdateNotification:)
                                                     name:kCoreDataManagerMessageUpdateNotification
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    __weak ChatViewController *weakSelf = self;

    [CoreDataManager messagesForChat:self.chat
                     completionQueue:dispatch_get_main_queue()
                     completionBlock:^(NSArray *array)
    {
        ChatViewController *strongSelf = weakSelf;

        if (! strongSelf) {
            return;
        }

        strongSelf.messages = [NSMutableArray arrayWithArray:array];
        [strongSelf.tableView reloadData];

        [strongSelf scrollToBottomAnimated:NO];
    }];

    [self updateIsTypingSection];
    [self updateSendButtonEnabled];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateLastReadDateAndChatsBadge];

    self.inputView.text = self.chat.enteredMessage;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [CoreDataManager editCDObjectWithBlock:^{
        self.chat.enteredMessage = self.inputView.text;

    } completionQueue:nil completionBlock:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [ToxManager sharedInstance].fileProgressDelegate = self;

    if (self.inputView.text.length) {
        [self.inputView becomeFirstResponder];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self adjustSubviews];
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
    UITableViewCell *tableViewCell;

    if (indexPath.section == SectionMessages) {
        CDMessage *message = self.messages[indexPath.row];

        if (message.text) {
            tableViewCell = [self messageTextCellForRowAtIndexPath:indexPath message:message];
        }
        else if (message.file) {
            tableViewCell = [self messageFileCellForRowAtIndexPath:indexPath message:message];
        }
        else if (message.pendingFile) {
            tableViewCell = [self messagePendingFileCellForRowAtIndexPath:indexPath message:message];
        }
    }
    else if (indexPath.section == SectionTyping) {
        ChatTypingCell *cell = [tableView dequeueReusableCellWithIdentifier:[ChatTypingCell reuseIdentifier]
                                                               forIndexPath:indexPath];
        [cell redraw];

        tableViewCell = cell;
    }

    return tableViewCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.showTypingSection ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SectionMessages) {
        return self.messages.count;
    }
    else if (section == SectionTyping) {
        return 1;
    }

    return 0;
}

#pragma mark -  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;

    if (indexPath.section == SectionMessages) {
        CDMessage *message = self.messages[indexPath.row];

        NSString *fullDateString = [self showFullDateForMessage:message atIndexPath:indexPath] ? @"placeholder" : nil;

        if (message.text) {
            if ([Helper isOutgoingMessage:message]) {
                height = [ChatOutgoingCell heightWithMessage:message.text.text fullDateString:fullDateString];
            }
            else {
                height = [ChatIncomingCell heightWithMessage:message.text.text fullDateString:fullDateString];
            }
        }
        else if (message.file) {
            height = [ChatFileCell height];
        }
        else if (message.pendingFile) {
            height = [ChatFileCell height];
        }
    }
    else if (indexPath.section == SectionTyping) {
        height = [ChatTypingCell height];
    }

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CDMessage *message = self.messages[indexPath.row];

    if (message.file) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        path = [path stringByAppendingPathComponent:message.file.documentPath];

        NSURL *url = [NSURL fileURLWithPath:path isDirectory:NO];

        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.documentInteractionController.delegate = self;
        self.documentInteractionController.name = message.file.fileName;

        [self.documentInteractionController presentOptionsMenuFromRect:self.view.frame inView:self.view animated:YES];
    }
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

#pragma mark -  UIGestureRecognizerDelegate

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

#pragma mark -  ChatFileCellDelegate

- (void)chatFileCell:(ChatFileCell *)cell answerButtonPressedWith:(BOOL)answer
{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];

    if (! path) {
        return;
    }

    if (path.section != SectionMessages) {
        return;
    }

    CDMessage *message = self.messages[path.row];

    [[ToxManager sharedInstance] acceptOrRefusePendingFileInMessage:message accept:answer];

    if (answer) {
        cell.type = ChatFileCellTypeIncomingDownloading;
    }
    else {
        cell.type = ChatFileCellTypeIncomingCanceled;
    }

    [cell redrawAnimated:YES];
}

- (void)chatFileCellPausePlayButtonPressed:(ChatFileCell *)cell
{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];

    if (! path) {
        return;
    }

    if (path.section != SectionMessages) {
        return;
    }

    CDMessage *message = self.messages[path.row];

    [[ToxManager sharedInstance] togglePauseForPendingFileInMessage:message];

    cell.isPaused = ! cell.isPaused;

    [cell redrawAnimated:NO];
}

#pragma mark -  UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
    return self.view.frame;
}

#pragma mark -  ToxManagerFileProgressDelegate

- (void)toxManagerProgressChanged:(CGFloat)progress
     forPendingFileWithFileNumber:(uint16_t)fileNumber
                     friendNumber:(int32_t)friendNumber
{
    for (NSIndexPath *path in [self.tableView indexPathsForVisibleRows]) {
        if (path.section != SectionMessages) {
            continue;
        }

        CDMessage *message = self.messages[path.row];

        if (! message.pendingFile) {
            continue;
        }

        if (message.pendingFile.state != CDMessagePendingFileStateActive) {
            continue;
        }

        if (message.pendingFile.fileNumber == fileNumber && message.pendingFile.friendNumber == friendNumber) {
            ChatFileCell *cell = (ChatFileCell *)[self.tableView cellForRowAtIndexPath:path];
            cell.loadedPercent = progress;
            [cell redrawLoadingPercentOnlyAnimated:YES];

            break;
        }
    }
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
    CDMessage *message = notification.userInfo[kCoreDataManagerCDMessageKey];

    if (! [message.chat isEqual:self.chat]) {
        return;
    }

    if (self.isViewLoaded && self.view.window) {
        // is visible
        [self updateLastReadDateAndChatsBadge];
    }

    NSIndexPath *lastMessagePath;

    if (self.messages.count) {
        lastMessagePath = [NSIndexPath indexPathForRow:self.messages.count-1 inSection:SectionMessages];
    }

    [self.messages addObject:message];

    @synchronized(self.tableView) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:self.messages.count-1 inSection:SectionMessages];

        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }

    [self changeIsTypingTo:NO];

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

- (void)messageUpdateNotification:(NSNotification *)notification
{
    CDMessage *message = notification.userInfo[kCoreDataManagerCDMessageKey];

    if (! [message.chat isEqual:self.chat]) {
        return;
    }

    @synchronized(self.tableView) {
        for (NSIndexPath *path in [self.tableView indexPathsForVisibleRows]) {
            if (path.section == SectionMessages) {
                CDMessage *m = self.messages[path.row];

                if ([m isEqual:message]) {
                    [self.tableView reloadRowsAtIndexPaths:@[path]
                                          withRowAnimation:UITableViewRowAnimationAutomatic];
                    return;
                }
            }
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
    [self updateIsTypingSection];
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
    [self.tableView registerClass:[ChatTypingCell class] forCellReuseIdentifier:[ChatTypingCell reuseIdentifier]];
    [self.tableView registerClass:[ChatFileCell class] forCellReuseIdentifier:[ChatFileCell reuseIdentifier]];

    [self.view addSubview:self.tableView];
}

- (void)createRecognizers
{
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(tableViewTapGesture:)];
    tapGR.cancelsTouchesInView = NO;
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

- (UITableViewCell *)messageTextCellForRowAtIndexPath:(NSIndexPath *)indexPath message:(CDMessage *)message
{
    ChatBasicCell *cell;

    if ([Helper isOutgoingMessage:message]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:[ChatOutgoingCell reuseIdentifier]
                                                    forIndexPath:indexPath];
    }
    else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:[ChatIncomingCell reuseIdentifier]
                                                    forIndexPath:indexPath];
    }

    cell.message = message.text.text;

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.date];

    cell.fullDateString = [self showFullDateForMessage:message atIndexPath:indexPath] ?
        [[TimeFormatter sharedInstance] stringFromDate:date type:TimeFormatterTypeRelativeDateAndTime] : nil;

    cell.hiddenDateString = [[TimeFormatter sharedInstance] stringFromDate:date type:TimeFormatterTypeTime];

    [cell redraw];

    return cell;
}

- (UITableViewCell *)messageFileCellForRowAtIndexPath:(NSIndexPath *)indexPath message:(CDMessage *)message
{
    ChatFileCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[ChatFileCell reuseIdentifier]
                                                              forIndexPath:indexPath];
    cell.delegate = self;
    cell.fileName = message.file.fileName;

    if (message.file.documentPath) {
        cell.type = ChatFileCellTypeIncomingLoaded;
    }
    else {
        cell.type = ChatFileCellTypeIncomingDeleted;
    }

    [cell redrawAnimated:NO];

    return cell;
}

- (UITableViewCell *)messagePendingFileCellForRowAtIndexPath:(NSIndexPath *)indexPath message:(CDMessage *)message
{
    ChatFileCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[ChatFileCell reuseIdentifier]
                                                              forIndexPath:indexPath];

    cell.delegate = self;
    cell.fileName = message.pendingFile.fileName;

    if (message.pendingFile.state == CDMessagePendingFileStateWaitingConfirmation) {
        cell.type = ChatFileCellTypeIncomingWaitingConfirmation;
        cell.fileSize = [NSString stringWithFormat:@"%llu", message.pendingFile.fileSize];
    }
    else if (message.pendingFile.state == CDMessagePendingFileStateActive ||
             message.pendingFile.state == CDMessagePendingFileStatePaused)
    {
        cell.type = ChatFileCellTypeIncomingDownloading;
        cell.loadedPercent = [[ToxManager sharedInstance] progressForPendingFileInMessage:message];

        cell.isPaused = (message.pendingFile.state == CDMessagePendingFileStatePaused);
    }
    else if (message.pendingFile.state == CDMessagePendingFileStateCanceled) {
        cell.type = ChatFileCellTypeIncomingCanceled;
    }

    [cell redrawAnimated:NO];

    return cell;
}

- (void)updateTitleView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];

    UILabel *label = [view addLabelWithTextColor:[UIColor blackColor] bgColor:[UIColor clearColor]];
    label.text = [self.friend nameToShow];
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
    NSIndexPath *path = self.showTypingSection ?
        [NSIndexPath indexPathForRow:0 inSection:SectionTyping] :
        [NSIndexPath indexPathForRow:self.messages.count-1 inSection:SectionMessages];

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

- (void)updateIsTypingSection
{
    [self changeIsTypingTo:self.friend.isTyping];
}

- (void)changeIsTypingTo:(BOOL)newTyping
{
    if (newTyping == self.showTypingSection) {
        return;
    }
    self.showTypingSection = newTyping;

    NSIndexSet *set = [NSIndexSet indexSetWithIndex:SectionTyping];

    if (newTyping) {
        @synchronized(self.tableView) {
            [self.tableView insertSections:set withRowAnimation:UITableViewRowAnimationBottom];
        }

        [self scrollToBottomAnimated:YES];
    }
    else {
        @synchronized(self.tableView) {
            [self.tableView deleteSections:set withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

- (void)updateSendButtonEnabled
{
    self.inputView.sendButtonEnabled = (self.friend.status != ToxFriendStatusOffline);
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

    } completionQueue:dispatch_get_main_queue() completionBlock:^{
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate updateBadgeForTab:AppDelegateTabIndexChats];
    }];
}

@end
