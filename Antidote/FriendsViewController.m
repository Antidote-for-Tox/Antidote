//
//  FriendsViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "FriendsViewController.h"
#import "UIViewController+Utilities.h"
#import "FriendsCell.h"
#import "ToxManager.h"
#import "FriendRequestsViewController.h"
#import "NSIndexSet+Utilities.h"
#import "Helper.h"
#import "AppDelegate+Utilities.h"

@interface FriendsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) ToxFriendsContainer *friendsContainer;

@end

@implementation FriendsViewController

#pragma mark -  Lifecycle

- (id)init
{
    self = [super init];

    if (self) {
        self.title = NSLocalizedString(@"Friends", @"Friends");

        self.friendsContainer = [ToxManager sharedInstance].friendsContainer;

        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
            initWithTitle:NSLocalizedString(@"Requests", @"Friends")
                    style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(requestsButtonPressed)];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateFriendsNotification:)
                                                     name:kToxFriendsContainerUpdateFriendsNotification
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
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self adjustSubviews];
}

#pragma mark -  Actions

- (void)requestsButtonPressed
{
    FriendRequestsViewController *frvc = [FriendRequestsViewController new];

    [self.navigationController pushViewController:frvc animated:YES];
}

#pragma mark -  UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:[FriendsCell reuseIdentifier]
                                                        forIndexPath:indexPath];

    ToxFriend *friend = [self.friendsContainer friendAtIndex:indexPath.row];

    cell.title = friend.associatedName ?: friend.clientId;
    cell.subtitle = friend.statusMessage;
    cell.status = [Helper toxFriendStatusToCircleStatus:friend.status];

    [cell redraw];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friendsContainer.friendsCount;
}

#pragma mark -  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FriendsCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    ToxFriend *friend = [self.friendsContainer friendAtIndex:indexPath.row];

    CDChat *chat = [[ToxManager sharedInstance] chatWithToxFriend:friend];

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    [delegate switchToChatsTabAndShowChatViewControllerWithChat:chat];
}

#pragma mark -  Notifications

- (void)updateFriendsNotification:(NSNotification *)notification
{
    NSIndexSet *inserted = notification.userInfo[kToxFriendsContainerUpdateKeyInsertedSet];
    NSIndexSet *removed = notification.userInfo[kToxFriendsContainerUpdateKeyRemovedSet];
    NSIndexSet *updated = notification.userInfo[kToxFriendsContainerUpdateKeyUpdatedSet];

    @synchronized(self.tableView) {
        [self.tableView beginUpdates];

        if (inserted.count) {
            [self.tableView insertRowsAtIndexPaths:[inserted arrayWithIndexPaths]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }

        if (removed.count) {
            [self.tableView deleteRowsAtIndexPaths:[removed arrayWithIndexPaths]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }

        if (updated.count) {
            [self.tableView reloadRowsAtIndexPaths:[updated arrayWithIndexPaths]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }

        [self.tableView endUpdates];
    }
}

#pragma mark -  Private

- (void)createTableView
{
    self.tableView = [UITableView new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];

    [self.tableView registerClass:[FriendsCell class] forCellReuseIdentifier:[FriendsCell reuseIdentifier]];

    [self.view addSubview:self.tableView];
}

- (void)adjustSubviews
{
    self.tableView.frame = self.view.bounds;
}

@end
