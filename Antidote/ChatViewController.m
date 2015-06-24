//
//  ChatViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 10.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "ChatViewController.h"
#import "OCTFriend.h"
#import "StatusCircleView.h"
#import "Helper.h"
#import "UIView+Utilities.h"
#import "ProfileManager.h"
#import "AppDelegate.h"
#import "ChatIncomingCell.h"
#import "ChatOutgoingCell.h"
#import "TimeFormatter.h"
#import "UITableViewCell+Utilities.h"
#import "OCTMessageAbstract.h"
#import "OCTMessageText.h"

@interface ChatViewController () <RBQFetchedResultsControllerDelegate>

@property (strong, nonatomic, readwrite) OCTChat *chat;
@property (strong, nonatomic, readwrite) OCTFriend *friend;

@property (strong, nonatomic, readwrite) RBQFetchedResultsController *messagesController;

@end

@implementation ChatViewController

#pragma mark -  Lifecycle

- (instancetype)initWithChat:(OCTChat *)chat
{
    self = [super initWithTableViewStyle:UITableViewStylePlain];

    if (! self) {
        return nil;
    }

    self.hidesBottomBarWhenPushed = YES;
    self.shakeToClearEnabled = NO;

    self.chat = chat;
    self.friend = [chat.friends lastObject];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chat.uniqueIdentifier == %@", chat.uniqueIdentifier];
    self.messagesController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeMessageAbstract
                                                                  predicate:predicate
                                                                   delegate:self];

    [self updateTitleView];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.inverted = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[ChatIncomingCell class] forCellReuseIdentifier:[ChatIncomingCell reuseIdentifier]];
    [self.tableView registerClass:[ChatOutgoingCell class] forCellReuseIdentifier:[ChatOutgoingCell reuseIdentifier]];

    [self.tableView slk_scrollToBottomAnimated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateLastReadDateAndChatsBadge];

    self.textView.text = self.chat.enteredText;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    OCTSubmanagerObjects *submanager = [AppContext sharedContext].profileManager.toxManager.objects;
    [submanager changeChat:self.chat enteredText:self.textView.text];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.textView.text.length) {
        [self.textView becomeFirstResponder];
    }
}

#pragma mark -  Override

- (void)textDidUpdate:(BOOL)animated
{
    [super textDidUpdate:animated];

    BOOL isTyping = self.textView.text.length > 0;
    [[AppContext sharedContext].profileManager.toxManager.chats setIsTyping:isTyping inChat:self.chat error:nil];
}

- (void)didPressRightButton:(id)sender
{
    [[AppContext sharedContext].profileManager.toxManager.chats sendMessageToChat:self.chat
                                                                             text:self.textView.text
                                                                             type:OCTToxMessageTypeNormal
                                                                            error:nil];

    [super didPressRightButton:sender];
}

#pragma mark -  RBQFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(RBQFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void) controller:(RBQFetchedResultsController *)controller
    didChangeObject:(RBQSafeRealmObject *)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(RBQFetchedResultsController *)controller
{
    @try {
        [self.tableView endUpdates];
    }
    @catch (NSException *ex) {
        [controller reset];
        [self.tableView reloadData];
    }
}

#pragma mark -  UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatBasicCell *basicCell;
    OCTMessageAbstract *message = [self.messagesController objectAtIndexPath:indexPath];

    if (message.messageText) {
        basicCell = [self messageTextCellForRowAtIndexPath:indexPath message:message];
    }

    basicCell.fullDateString = [self showFullDateForMessage:message atIndexPath:indexPath] ?
                               [[TimeFormatter sharedInstance] stringFromDate : message.date type:TimeFormatterTypeRelativeDateAndTime] : nil;

    basicCell.hiddenDateString = [[TimeFormatter sharedInstance] stringFromDate:message.date type:TimeFormatterTypeTime];

    [basicCell redraw];

    return basicCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messagesController numberOfRowsForSectionIndex:section];
}

#pragma mark -  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;

    OCTMessageAbstract *message = [self.messagesController objectAtIndexPath:indexPath];

    NSString *fullDateString = [self showFullDateForMessage:message atIndexPath:indexPath] ? @"placeholder" : nil;

    if (message.messageText) {
        if ([message isOutgoing]) {
            height = [ChatOutgoingCell heightWithMessage:message.messageText.text fullDateString:fullDateString];
        }
        else {
            height = [ChatIncomingCell heightWithMessage:message.messageText.text fullDateString:fullDateString];
        }
    }

    return height;
}

#pragma mark -  Private

- (void)updateTitleView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];

    UILabel *label = [view addLabelWithTextColor:[UIColor blackColor] bgColor:[UIColor clearColor]];
    label.text = self.friend.nickname;
    [label sizeToFit];

    StatusCircleView *statusView = [StatusCircleView new];
    statusView.status = [Helper circleStatusFromFriend:self.friend];
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

- (void)updateLastReadDateAndChatsBadge
{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    [[AppContext sharedContext].profileManager.toxManager.objects changeChat:self.chat lastReadDateInterval:interval];

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate updateBadgeForTab:AppDelegateTabIndexChats];
}

- (ChatBasicCell *)messageTextCellForRowAtIndexPath:(NSIndexPath *)indexPath message:(OCTMessageAbstract *)message
{
    ChatBasicMessageCell *cell;

    if ([message isOutgoing]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:[ChatOutgoingCell reuseIdentifier]
                                                    forIndexPath:indexPath];

        ((ChatOutgoingCell *)cell).isDelivered = message.messageText.isDelivered;
    }
    else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:[ChatIncomingCell reuseIdentifier]
                                                    forIndexPath:indexPath];
    }

    cell.message = message.messageText.text;

    return cell;
}

- (BOOL)showFullDateForMessage:(OCTMessageAbstract *)message atIndexPath:(NSIndexPath *)path
{
    if (path.row == 0) {
        return YES;
    }

    NSIndexPath *previousPath = [NSIndexPath indexPathForRow:path.row-1 inSection:path.section];
    OCTMessageAbstract *previous = [self.messagesController objectAtIndexPath:previousPath];

    if (! [[TimeFormatter sharedInstance] areSameDays:message.date and:previous.date]) {
        return YES;
    }

    NSTimeInterval delta = [message.date timeIntervalSinceDate:previous.date];

    if (delta > 5 * 60 * 60) {
        return YES;
    }

    return NO;
}

@end
