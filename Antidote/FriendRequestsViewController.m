//
//  FriendRequestsViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "FriendRequestsViewController.h"
#import "UIViewController+Utilities.h"
#import "ToxManager.h"
#import "FriendRequestsCell.h"

@interface FriendRequestsViewController () <UITableViewDataSource, UITableViewDelegate, FriendRequestsCellDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) ToxFriendsContainer *friendsContainer;

@end

@implementation FriendRequestsViewController

#pragma mark -  Lifecycle

- (id)init
{
    self = [super init];

    if (self) {
        self.title = NSLocalizedString(@"Friend requests", @"Friend requests");

        self.friendsContainer = [ToxManager sharedInstance].friendsContainer;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateRequestsNotification:)
                                                     name:kToxFriendsContainerUpdateRequestsNotification
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

#pragma mark -  UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendRequestsCell *cell = [tableView dequeueReusableCellWithIdentifier:[FriendRequestsCell reuseIdentifier]
                                                        forIndexPath:indexPath];
    cell.delegate = self;

    ToxFriendRequest *request = [self.friendsContainer requestAtIndex:indexPath.row];

    cell.title = request.publicKey;
    cell.subtitle = request.message;

    [cell redraw];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friendsContainer.requestsCount;
}

#pragma mark -  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FriendRequestsCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -  FriendRequestsCellDelegate

- (void)friendRequestCellAddButtonPressed:(FriendRequestsCell *)cell
{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];

    ToxFriendRequest *request = [self.friendsContainer requestAtIndex:path.row];

    BOOL wasError = NO;

    [[ToxManager sharedInstance] approveFriendRequest:request wasError:&wasError];

    if (wasError) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", @"Error")
                                    message:NSLocalizedString(@"Something went wrong", @"Error")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", @"Error")
                          otherButtonTitles:nil] show];
    }
}

#pragma mark -  Notifications

- (void)updateRequestsNotification:(NSNotification *)notification
{
    NSIndexSet *inserted = notification.userInfo[kToxFriendsContainerUpdateKeyInsertedSet];
    NSIndexSet *removed = notification.userInfo[kToxFriendsContainerUpdateKeyRemovedSet];

    @synchronized(self.tableView) {
        [self.tableView beginUpdates];

        if (inserted.count) {
            [self.tableView insertRowsAtIndexPaths:[self pathsArrayFromIndexSet:inserted]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }

        if (removed.count) {
            [self.tableView deleteRowsAtIndexPaths:[self pathsArrayFromIndexSet:removed]
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

    [self.tableView registerClass:[FriendRequestsCell class]
           forCellReuseIdentifier:[FriendRequestsCell reuseIdentifier]];

    [self.view addSubview:self.tableView];
}

- (void)adjustSubviews
{
    self.tableView.frame = self.view.bounds;
}

- (NSArray *)pathsArrayFromIndexSet:(NSIndexSet *)set
{
    NSMutableArray *array = [NSMutableArray new];

    [set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:idx inSection:0];
        [array addObject:path];
    }];

    return [array copy];
}

@end
