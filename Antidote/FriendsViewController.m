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
#import "FriendRequestsCell.h"
#import "NSIndexSet+Utilities.h"
#import "AppDelegate+Utilities.h"
#import "AddFriendViewController.h"
#import "FriendCardViewController.h"
#import "UIAlertView+BlocksKit.h"
#import "TimeFormatter.h"
#import "UIColor+Utilities.h"
#import "UITableViewCell+Utilities.h"

@interface FriendsViewController () <UITableViewDataSource, UITableViewDelegate, FriendRequestsCellDelegate>

@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) ToxFriendsContainer *friendsContainer;

@end

@implementation FriendsViewController

#pragma mark -  Lifecycle

- (id)init
{
    self = [super init];

    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.title = NSLocalizedString(@"Friends", @"Friends");

        self.friendsContainer = [ToxManager sharedInstance].friendsContainer;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateFriendsNotification:)
                                                     name:kToxFriendsContainerUpdateFriendsNotification
                                                   object:nil];
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
    self.view.backgroundColor = [UIColor uColorOpaqueWithWhite:245];

    [self createSegmentedControl];
    [self createTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateBarButtonItem];

    [self updateSegmentedControlRequestTitle];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self adjustSubviews];
}

#pragma mark -  Actions

- (void)sortButtonPressed
{
    self.friendsContainer.friendsSort = (self.friendsContainer.friendsSort + 1) % 2;

    [self updateBarButtonItem];
}

- (void)addButtonPressed
{
    AddFriendViewController *afvc = [AddFriendViewController new];

    [self.navigationController pushViewController:afvc animated:YES];
}

- (void)segmentedControlPressed:(UISegmentedControl *)control
{
    [self.tableView reloadData];
    [self updateBarButtonItem];
}

#pragma mark -  Public

- (void)switchToTab:(FriendsViewControllerTab)tab
{
    if (! self.segmentedControl) {
        // it seems that view isn't loaded, so we load it
        [self view];
    }

    if (self.segmentedControl.selectedSegmentIndex == tab) {
        return;
    }

    self.segmentedControl.selectedSegmentIndex = tab;

    [self segmentedControlPressed:self.segmentedControl];
}

#pragma mark -  UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == FriendsViewControllerTabFriends) {
        return [self friendsCellForRowAtIndexPath:indexPath];
    }
    else if (self.segmentedControl.selectedSegmentIndex == FriendsViewControllerTabRequests) {
        return [self requestsCellForRowAtIndexPath:indexPath];
    }

    return [UITableViewCell new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segmentedControl.selectedSegmentIndex == FriendsViewControllerTabFriends) {
        return self.friendsContainer.friendsCount;
    }
    else if (self.segmentedControl.selectedSegmentIndex == FriendsViewControllerTabRequests) {
        return self.friendsContainer.requestsCount;
    }

    return 0;
}

- (void)  tableView:(UITableView *)tableView
 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
  forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == FriendsViewControllerTabFriends) {
        [self friendsCommitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
    else if (self.segmentedControl.selectedSegmentIndex == FriendsViewControllerTabRequests) {
        [self requestsCommitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

#pragma mark -  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == FriendsViewControllerTabFriends) {
        return [FriendsCell height];
    }
    else if (self.segmentedControl.selectedSegmentIndex == FriendsViewControllerTabRequests) {
        return [FriendRequestsCell height];
    }

    return 0.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.segmentedControl.selectedSegmentIndex == FriendsViewControllerTabFriends) {
        return [self friendsDidSelectRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == FriendsViewControllerTabFriends) {
        ToxFriend *friend = [self.friendsContainer friendAtIndex:indexPath.row];

        FriendCardViewController *fcvc = [[FriendCardViewController alloc] initWithToxFriend:friend];
        [self.navigationController pushViewController:fcvc animated:YES];
    }
}

#pragma mark -  FriendRequestsCellDelegate

- (void)friendRequestCellAddButtonPressed:(FriendRequestsCell *)cell
{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];

    ToxFriendRequest *request = [self.friendsContainer requestAtIndex:path.row];

    BOOL wasLastRequest = (self.friendsContainer.requestsCount == 1);

    __weak FriendsViewController *weakSelf = self;

    [[ToxManager sharedInstance] approveFriendRequest:request withBlock:^(BOOL wasError) {
        if (wasError) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", @"Error")
                                        message:NSLocalizedString(@"Something went wrong", @"Error")
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Ok", @"Error")
                              otherButtonTitles:nil] show];
        }

        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate updateBadgeForTab:AppDelegateTabIndexFriends];

        if (wasLastRequest) {
            [weakSelf switchToTab:FriendsViewControllerTabFriends];
        }
    }];
}

#pragma mark -  Notifications

- (void)updateFriendsNotification:(NSNotification *)notification
{
    if (self.segmentedControl.selectedSegmentIndex != FriendsViewControllerTabFriends) {
        return;
    }

    if (! self.tableView) {
        return;
    }

    NSIndexSet *inserted = notification.userInfo[kToxFriendsContainerUpdateKeyInsertedSet];
    NSIndexSet *removed = notification.userInfo[kToxFriendsContainerUpdateKeyRemovedSet];
    NSIndexSet *updated = notification.userInfo[kToxFriendsContainerUpdateKeyUpdatedSet];

    @synchronized(self.tableView) {
        NSInteger newNumberOfRows = [self.tableView numberOfRowsInSection:0] + inserted.count - removed.count;

        if (newNumberOfRows != [self tableView:self.tableView numberOfRowsInSection:0]) {
            DDLogWarn(@"FriendsViewController: inconsistent data, reloding table view");
            [self.tableView reloadData];
        }
        else {
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
}

- (void)updateRequestsNotification:(NSNotification *)notification
{
    [self updateSegmentedControlRequestTitle];

    if (self.segmentedControl.selectedSegmentIndex != FriendsViewControllerTabRequests) {
        return;
    }

    NSIndexSet *inserted = notification.userInfo[kToxFriendsContainerUpdateKeyInsertedSet];
    NSIndexSet *removed = notification.userInfo[kToxFriendsContainerUpdateKeyRemovedSet];

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

        [self.tableView endUpdates];
    }
}

#pragma mark -  Private

- (void)createSegmentedControl
{
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[
        NSLocalizedString(@"Friends", @"Friends"),
        @"Requests",
    ]];
    self.segmentedControl.tintColor = [[AppContext sharedContext].appearance textMainColor];
    self.segmentedControl.selectedSegmentIndex = FriendsViewControllerTabFriends;

    [self.segmentedControl addTarget:self
                              action:@selector(segmentedControlPressed:)
                    forControlEvents:UIControlEventValueChanged];

    self.navigationItem.titleView = self.segmentedControl;

    [self updateSegmentedControlRequestTitle];
}

- (void)createTableView
{
    self.tableView = [UITableView new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.tableView registerClass:[FriendsCell class] forCellReuseIdentifier:[FriendsCell reuseIdentifier]];
    [self.tableView registerClass:[FriendRequestsCell class]
           forCellReuseIdentifier:[FriendRequestsCell reuseIdentifier]];

    [self.view addSubview:self.tableView];
}

- (void)adjustSubviews
{
    CGRect frame = self.segmentedControl.frame;
    frame.size.height = 25.0;
    self.segmentedControl.frame = frame;

    self.tableView.frame = self.view.bounds;
}

- (void)updateBarButtonItem
{
    if (self.segmentedControl.selectedSegmentIndex != FriendsViewControllerTabFriends) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;

        return;
    }

    UIImage *image;

    if (self.friendsContainer.friendsSort == ToxFriendsContainerSortByName) {
        image = [UIImage imageNamed:@"friends-sort-alphabet"];
    }
    else if (self.friendsContainer.friendsSort == ToxFriendsContainerSortByStatus) {
        image = [UIImage imageNamed:@"friends-sort-status"];
    }
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(sortButtonPressed)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                             target:self
                             action:@selector(addButtonPressed)];

}

- (FriendsCell *)friendsCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[FriendsCell reuseIdentifier]
                                                             forIndexPath:indexPath];

    ToxFriend *friend = [self.friendsContainer friendAtIndex:indexPath.row];

    cell.textLabel.text = [friend nameToShow];
    cell.imageView.image = [AvatarManager avatarInCurrentProfileWithClientId:friend.clientId
                                                    orCreateAvatarFromString:[friend nameToShow]
                                                                    withSide:30.0];
    cell.status = [Helper toxFriendStatusToCircleStatus:friend.status];

    if (friend.status == ToxFriendStatusOffline) {
        if (friend.lastSeenOnline) {
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"last seen %@", @"Friends"),
                [[TimeFormatter sharedInstance] stringFromDate:friend.lastSeenOnline
                                                          type:TimeFormatterTypeRelativeDateAndTime]];
        }
    }
    else {
        cell.detailTextLabel.text = friend.statusMessage;
    }

    if (! cell.detailTextLabel.text.length) {
        // add whitespace for nice alignment

        cell.detailTextLabel.text = @" ";
    }

    return cell;
}

- (FriendRequestsCell *)requestsCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendRequestsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[FriendRequestsCell reuseIdentifier]
                                                                    forIndexPath:indexPath];
    cell.delegate = self;

    ToxFriendRequest *request = [self.friendsContainer requestAtIndex:indexPath.row];

    cell.title = request.publicKey;
    cell.subtitle = request.message;

    [cell redraw];

    return cell;
}

- (void)friendsCommitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __weak FriendsViewController *weakSelf = self;

        NSString *friendTitle = NSLocalizedString(@"Are you sure you want to delete a friend?", @"Friends");
        NSString *chatTitle = NSLocalizedString(@"Remove private chat with this friend?", @"Friends");

        UIAlertView *friendAlert = [UIAlertView bk_alertViewWithTitle:friendTitle];

        [friendAlert bk_addButtonWithTitle:NSLocalizedString(@"Yes", @"Friends") handler:^{
            ToxFriend *friend = [weakSelf.friendsContainer friendAtIndex:indexPath.row];

            [[ToxManager sharedInstance] chatWithToxFriend:friend completionBlock:^(CDChat *chat) {
                UIAlertView *chatAlert = [UIAlertView bk_alertViewWithTitle:chatTitle];

                [chatAlert bk_addButtonWithTitle:NSLocalizedString(@"Yes", @"Friends") handler:^{
                    [CoreDataManager removeChatWithAllMessages:chat completionQueue:nil completionBlock:nil];
                }];

                [chatAlert bk_setCancelButtonWithTitle:NSLocalizedString(@"No", @"Friends") handler:nil];

                [chatAlert show];
            }];

            [[ToxManager sharedInstance] removeFriend:friend];
        }];

        [friendAlert bk_setCancelButtonWithTitle:NSLocalizedString(@"No", @"Friends") handler:^{
            [weakSelf.tableView setEditing:NO animated:YES];
        }];

        [friendAlert show];
    }
}

- (void)requestsCommitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __weak FriendsViewController *weakSelf = self;

        NSString *friendTitle = NSLocalizedString(@"Are you sure you want to delete friend request?", @"Friend requests");

        UIAlertView *friendAlert = [UIAlertView bk_alertViewWithTitle:friendTitle];

        [friendAlert bk_addButtonWithTitle:NSLocalizedString(@"Yes", @"Friend requestss") handler:^{
            ToxFriendRequest *request = [weakSelf.friendsContainer requestAtIndex:indexPath.row];

            [[ToxManager sharedInstance] removeFriendRequest:request];
        }];

        [friendAlert bk_setCancelButtonWithTitle:NSLocalizedString(@"No", @"Friend requestss") handler:^{
            [weakSelf.tableView setEditing:NO animated:YES];
        }];

        [friendAlert show];
    }
}

- (void)friendsDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ToxFriend *friend = [self.friendsContainer friendAtIndex:indexPath.row];

    [[ToxManager sharedInstance] chatWithToxFriend:friend completionBlock:^(CDChat *chat) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

        [delegate switchToChatsTabAndShowChatViewControllerWithChat:chat];
    }];
}

- (void)updateSegmentedControlRequestTitle
{
    NSUInteger number = [[ToxManager sharedInstance].friendsContainer requestsCount];

    NSString *title = NSLocalizedString(@"Requests", @"Friends");

    if (number > 0) {
        title = [title stringByAppendingFormat:@" (%lu)", (unsigned long)number];
    }

    [self.segmentedControl setTitle:title forSegmentAtIndex:FriendsViewControllerTabRequests];
}

@end
