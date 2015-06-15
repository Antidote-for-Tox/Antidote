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
#import "OCTArray.h"
#import "ProfileManager.h"
#import "AppDelegate.h"
#import "ChatIncomingCell.h"
#import "ChatOutgoingCell.h"
#import "TimeFormatter.h"
#import "UITableViewCell+Utilities.h"

@interface ChatViewController () <OCTArrayDelegate>

@property (strong, nonatomic, readwrite) OCTChat *chat;
@property (strong, nonatomic, readwrite) OCTFriend *friend;
@property (strong, nonatomic, readwrite) OCTArray *allMessages;

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

    self.allMessages = [[AppContext sharedContext].profileManager.toxManager.chats allMessagesInChat:self.chat];
    self.allMessages.delegate = self;

    [self updateTitleView];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(friendUpdateNotification:)
                                                 name:kProfileManagerFriendUpdateNotification
                                               object:nil];
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

    self.chat.enteredText = self.textView.text;
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

#pragma mark -  OCTArrayDelegate

- (void)OCTArrayWasUpdated:(OCTArray *)array
{
    [self.tableView reloadData];
}

#pragma mark -  UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatBasicCell *basicCell;
    OCTMessageAbstract *message = [self.allMessages objectAtIndex:indexPath.row];

    if ([message isKindOfClass:[OCTMessageText class]]) {
        basicCell = [self messageTextCellForRowAtIndexPath:indexPath message:(OCTMessageText *)message];
    }

    basicCell.fullDateString = [self showFullDateForMessage:message atIndexPath:indexPath] ?
                               [[TimeFormatter sharedInstance] stringFromDate : message.date type:TimeFormatterTypeRelativeDateAndTime] : nil;

    basicCell.hiddenDateString = [[TimeFormatter sharedInstance] stringFromDate:message.date type:TimeFormatterTypeTime];

    [basicCell redraw];

    return basicCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allMessages.count;
}

#pragma mark -  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;

    OCTMessageAbstract *message = [self.allMessages objectAtIndex:indexPath.row];

    NSString *fullDateString = [self showFullDateForMessage:message atIndexPath:indexPath] ? @"placeholder" : nil;

    if ([message isKindOfClass:[OCTMessageText class]]) {
        OCTMessageText *messageText = (OCTMessageText *)message;
        if ([messageText isOutgoing]) {
            height = [ChatOutgoingCell heightWithMessage:messageText.text fullDateString:fullDateString];
        }
        else {
            height = [ChatIncomingCell heightWithMessage:messageText.text fullDateString:fullDateString];
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
    self.chat.lastReadDate = [NSDate date];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate updateBadgeForTab:AppDelegateTabIndexChats];
}

- (ChatBasicCell *)messageTextCellForRowAtIndexPath:(NSIndexPath *)indexPath message:(OCTMessageText *)message
{
    ChatBasicMessageCell *cell;

    if ([message isOutgoing]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:[ChatOutgoingCell reuseIdentifier]
                                                    forIndexPath:indexPath];

        ((ChatOutgoingCell *)cell).isDelivered = message.isDelivered;
    }
    else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:[ChatIncomingCell reuseIdentifier]
                                                    forIndexPath:indexPath];
    }

    cell.message = message.text;

    return cell;
}

- (BOOL)showFullDateForMessage:(OCTMessageAbstract *)message atIndexPath:(NSIndexPath *)path
{
    if (path.row == 0) {
        return YES;
    }

    OCTMessageAbstract *previous = [self.allMessages objectAtIndex:path.row-1];

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
