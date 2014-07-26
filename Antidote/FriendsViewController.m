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

//    cell.title = friend.publicKey;
    cell.status = StatusCircleStatusFriendRequest;
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
