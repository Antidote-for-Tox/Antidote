//
//  FriendsViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <BlocksKit/UIActionSheet+BlocksKit.h>

#import "FriendsViewController.h"
#import "UIViewController+Utilities.h"
#import "FriendsCell.h"
#import "NSIndexSet+Utilities.h"
#import "AddFriendViewController.h"
#import "FriendCardViewController.h"
#import "TimeFormatter.h"
#import "UIColor+Utilities.h"
#import "UITableViewCell+Utilities.h"
#import "ProfileManager.h"
#import "AppearanceManager.h"
#import "Helper.h"
#import "OCTFriendRequest.h"
#import "AvatarsManager.h"
#import "UserDefaultsManager.h"
#import "FriendRequestViewController.h"

typedef NS_ENUM(NSInteger, FriendsSort) {
    FriendsSortByNickname = 0,
    FriendsSortByStatus,
    __FriendsSortCount,
};

static const CGFloat kCellHeight = 44.0;
static const CGFloat kSegmentedControlHeight = 25.0;

@interface FriendsViewController () <UITableViewDataSource,
                                     UITableViewDelegate,
                                     RBQFetchedResultsControllerDelegate,
                                     FriendRequestViewControllerDelegate>

@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) RBQFetchedResultsController *friendsController;
@property (strong, nonatomic) RBQFetchedResultsController *friendRequestsController;

@end

@implementation FriendsViewController

#pragma mark -  Lifecycle

- (id)init
{
    self = [super init];

    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.title = NSLocalizedString(@"Friends", @"Friends");

        self.friendsController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeFriend
                                                                     predicate:nil
                                                                      delegate:self];

        self.friendRequestsController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeFriendRequest
                                                                             delegate:self];

        [self updateFriendsControllerWithCurrentFriendsSort];
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    FriendsViewControllerTab tab = FriendsViewControllerTabFriends;

    if ([self.friendsController numberOfRowsForSectionIndex:0]) {
        tab = FriendsViewControllerTabFriends;
    }
    else if ([self.friendRequestsController numberOfRowsForSectionIndex:0]) {
        tab = FriendsViewControllerTabRequests;
    }

    [self switchToTab:tab];
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
    FriendsSort sort = [AppContext sharedContext].userDefaults.uFriendsSort.integerValue;
    if (++sort >= __FriendsSortCount) {
        sort = 0;
    }

    [AppContext sharedContext].userDefaults.uFriendsSort = @(sort);

    [self updateFriendsControllerWithCurrentFriendsSort];
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
    FriendsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[FriendsCell reuseIdentifier]
                                                             forIndexPath:indexPath];

    FriendsViewControllerTab tab = self.segmentedControl.selectedSegmentIndex;
    NSString *avatarString;

    switch (tab) {
        case FriendsViewControllerTabFriends: {
            OCTFriend *friend = [self.friendsController objectAtIndexPath:indexPath];

            cell.textLabel.text = friend.nickname;
            cell.detailTextLabel.text = [self detailTextLabelForFriend:friend];
            cell.showStatusView = YES;
            cell.status = [Helper circleStatusFromFriend:friend];
            avatarString = friend.nickname;

            break;
        }
        case FriendsViewControllerTabRequests: {
            OCTFriendRequest *request = [self.friendRequestsController objectAtIndexPath:indexPath];

            cell.textLabel.text = request.publicKey;
            cell.detailTextLabel.text = request.message;
            cell.showStatusView = NO;
            avatarString = @"?";

            break;
        }
    }

    cell.imageView.image = [[AppContext sharedContext].avatars avatarFromString:avatarString
                                                                       diameter:kFriendsCellImageViewSize];


    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    FriendsViewControllerTab tab = self.segmentedControl.selectedSegmentIndex;

    switch (tab) {
        case FriendsViewControllerTabFriends:
            return [self.friendsController numberOfRowsForSectionIndex:section];
        case FriendsViewControllerTabRequests:
            return [self.friendRequestsController numberOfRowsForSectionIndex:section];
    }
}

- (void)     tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendsViewControllerTab tab = self.segmentedControl.selectedSegmentIndex;

    switch (tab) {
        case FriendsViewControllerTabFriends:
            [self friendsCommitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
            break;
        case FriendsViewControllerTabRequests:
            [self requestsCommitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
            break;
    }
}

#pragma mark -  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    FriendsViewControllerTab tab = self.segmentedControl.selectedSegmentIndex;

    switch (tab) {
        case FriendsViewControllerTabFriends:
            return [self friendsDidSelectRowAtIndexPath:indexPath];
        case FriendsViewControllerTabRequests:
            return [self friendRequestDidSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark -  RBQFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(RBQFetchedResultsController *)controller
{
    if (! [self isCurrentFetchedRequestController:controller]) {
        return;
    }

    [self.tableView beginUpdates];
}

- (void) controller:(RBQFetchedResultsController *)controller
    didChangeObject:(RBQSafeRealmObject *)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    if (! [self isCurrentFetchedRequestController:controller]) {
        return;
    }

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
    [self updateSegmentedControlRequestTitle];

    if (! [self isCurrentFetchedRequestController:controller]) {
        return;
    }

    @try {
        [self.tableView endUpdates];
    }
    @catch (NSException *ex) {
        [controller reset];
        [self.tableView reloadData];
    }
}

#pragma mark -  FriendRequestViewControllerDelegate

- (void)friendRequestViewControllerAcceptedRequest:(FriendRequestViewController *)controller
{
    if (! [self.friendRequestsController numberOfRowsForSectionIndex:0]) {
        [self switchToTab:FriendsViewControllerTabFriends];
    }
}

- (void)friendRequestViewControllerRemovedRequest:(FriendRequestViewController *)controller
{
    if (! [self.friendRequestsController numberOfRowsForSectionIndex:0]) {
        [self switchToTab:FriendsViewControllerTabFriends];
    }
}

#pragma mark -  Private

- (void)updateFriendsControllerWithCurrentFriendsSort
{
    FriendsSort sort = [AppContext sharedContext].userDefaults.uFriendsSort.integerValue;

    switch (sort) {
        case FriendsSortByNickname:
            self.friendsController.fetchRequest.sortDescriptors = @[
                [RLMSortDescriptor sortDescriptorWithProperty:@"nickname" ascending:YES],
            ];
            break;
        case FriendsSortByStatus:
            self.friendsController.fetchRequest.sortDescriptors = @[
                [RLMSortDescriptor sortDescriptorWithProperty:@"isConnected" ascending:NO],
                [RLMSortDescriptor sortDescriptorWithProperty:@"status" ascending:NO],
                [RLMSortDescriptor sortDescriptorWithProperty:@"nickname" ascending:YES],
            ];
            break;
        case __FriendsSortCount:
            // nop
            break;
    }
    [self.friendsController performFetch];
    [self.tableView reloadData];

}

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

    [self.view addSubview:self.tableView];
}

- (void)adjustSubviews
{
    self.tableView.frame = self.view.bounds;
}

- (void)updateBarButtonItem
{
    if (self.segmentedControl.selectedSegmentIndex != FriendsViewControllerTabFriends) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    else {
        UIImage *image;

        FriendsSort sort = [AppContext sharedContext].userDefaults.uFriendsSort.integerValue;

        switch (sort) {
            case FriendsSortByNickname:
                image = [UIImage imageNamed:@"friends-sort-alphabet"];
                break;
            case FriendsSortByStatus:
                image = [UIImage imageNamed:@"friends-sort-status"];
                break;
            case __FriendsSortCount:
                // nop
                break;
        }
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(sortButtonPressed)];
    }


    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                   target:self
                                                                   action:@selector(addButtonPressed)];
}

- (NSString *)detailTextLabelForFriend:(OCTFriend *)friend
{
    NSString *text;

    if (friend.connectionStatus == OCTToxConnectionStatusNone) {
        if (friend.lastSeenOnline) {
            text = [NSString stringWithFormat:NSLocalizedString(@"last seen %@", @"Friends"),
                    [[TimeFormatter sharedInstance] stringFromDate:friend.lastSeenOnline
                                                              type:TimeFormatterTypeRelativeDateAndTime]];
        }
    }
    else {
        text = friend.statusMessage;
    }

    if (! text.length) {
        // add whitespace for nice alignment
        text = @" ";
    }

    return text;
}

- (void)friendsCommitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        weakself;

        NSString *title = NSLocalizedString(@"Are you sure you want to remove a friend?\nThis will remove all chat history as well.", @"Friends");
        UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:title];

        [sheet bk_setDestructiveButtonWithTitle:NSLocalizedString(@"Remove", @"Friends") handler:^{
            strongself;
            OCTFriend *friend = [self.friendsController objectAtIndexPath:indexPath];
            OCTChat *chat = [[AppContext sharedContext].profileManager.toxManager.chats getOrCreateChatWithFriend:friend];

            [[AppContext sharedContext].profileManager.toxManager.friends removeFriend:friend error:nil];
            [[AppContext sharedContext].profileManager.toxManager.chats removeChatWithAllMessages:chat];
        }];

        [sheet bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Friends") handler:^{
            strongself;
            [self.tableView setEditing:NO animated:YES];
        }];

        [sheet showInView:self.view];
    }
}

- (void)requestsCommitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        weakself;

        NSString *title = NSLocalizedString(@"Are you sure you want to remove friend request?", @"Friends");
        UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:title];

        [sheet bk_setDestructiveButtonWithTitle:NSLocalizedString(@"Remove", @"Friends") handler:^{
            strongself;

            OCTFriendRequest *request = [self.friendRequestsController objectAtIndexPath:indexPath];
            [[AppContext sharedContext].profileManager.toxManager.friends removeFriendRequest:request];
        }];

        [sheet bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Friends") handler:^{
            strongself;

            [self.tableView setEditing:NO animated:YES];
        }];

        [sheet showInView:self.view];
    }
}

- (void)friendsDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OCTFriend *friend = [self.friendsController objectAtIndexPath:indexPath];

    FriendCardViewController *fcvc = [[FriendCardViewController alloc] initWithToxFriend:friend];
    [self.navigationController pushViewController:fcvc animated:YES];
}

- (void)friendRequestDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OCTFriendRequest *request = [self.friendRequestsController objectAtIndexPath:indexPath];
    FriendRequestViewController *controller = [[FriendRequestViewController alloc] initWithRequest:request];
    controller.delegate = self;

    [self.navigationController pushViewController:controller animated:YES];
}

- (void)updateSegmentedControlRequestTitle
{
    NSUInteger number = [self.friendRequestsController numberOfRowsForSectionIndex:0];

    NSString *title = NSLocalizedString(@"Requests", @"Friends");

    if (number > 0) {
        title = [title stringByAppendingFormat:@" (%lu)", (unsigned long)number];
    }

    [self.segmentedControl setTitle:title forSegmentAtIndex:FriendsViewControllerTabRequests];
    [self.segmentedControl sizeToFit];

    CGRect frame = self.segmentedControl.frame;
    frame.size.height = kSegmentedControlHeight;
    self.segmentedControl.frame = frame;
}

- (BOOL)isCurrentFetchedRequestController:(RBQFetchedResultsController *)controller
{
    if (self.segmentedControl.selectedSegmentIndex == FriendsViewControllerTabFriends) {
        if (! [controller isEqual:self.friendsController]) {
            return NO;
        }
    }
    else if (self.segmentedControl.selectedSegmentIndex == FriendsViewControllerTabRequests) {
        if (! [controller isEqual:self.friendRequestsController]) {
            return NO;
        }
    }

    return YES;
}

@end
