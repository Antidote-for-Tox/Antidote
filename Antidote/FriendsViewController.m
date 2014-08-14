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
#import "AddFriendViewController.h"
#import "FriendCardViewController.h"
#import "UIAlertView+BlocksKit.h"
#import "CoreDataManager+Chat.h"
#import "TimeFormatter.h"
#import "AvatarFactory.h"
#import "UIColor+Utilities.h"
#import "FriendsFilterView.h"

@interface FriendsViewController () <UITableViewDataSource, UITableViewDelegate, FriendsFilterViewDelegate>

@property (strong, nonatomic) UIButton *titleButton;
@property (strong, nonatomic) FriendsFilterView *filterView;

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
        [self createTitleButton];

        self.friendsContainer = [ToxManager sharedInstance].friendsContainer;

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                 target:self
                                 action:@selector(addButtonPressed)];

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateLeftBarButtonItem];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self adjustSubviews];
}

#pragma mark -  Actions

- (void)titleButtonPressed
{
    if (self.filterView) {
        [self hideFilterView];
    }
    else {
        [self showFilterView];
    }
}

- (void)requestsButtonPressed
{
    FriendRequestsViewController *frvc = [FriendRequestsViewController new];

    [self.navigationController pushViewController:frvc animated:YES];
}

- (void)addButtonPressed
{
    AddFriendViewController *afvc = [AddFriendViewController new];

    [self.navigationController pushViewController:afvc animated:YES];
}

#pragma mark -  UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:[FriendsCell reuseIdentifier]
                                                        forIndexPath:indexPath];

    ToxFriend *friend = [self.friendsContainer friendAtIndex:indexPath.row];

    cell.textLabel.text = friend.associatedName ?: friend.clientId;
    cell.imageView.image = [AvatarFactory avatarFromString:cell.textLabel.text side:30.0];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friendsContainer.friendsCount;
}

- (void)  tableView:(UITableView *)tableView
 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
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
                [[ToxManager sharedInstance] removeFriend:friend];

                UIAlertView *chatAlert = [UIAlertView bk_alertViewWithTitle:chatTitle];

                [chatAlert bk_addButtonWithTitle:NSLocalizedString(@"Yes", @"Friends") handler:^{
                    [CoreDataManager removeChatWithAllMessages:chat completionQueue:nil completionBlock:nil];
                }];

                [chatAlert bk_setCancelButtonWithTitle:NSLocalizedString(@"No", @"Friends") handler:nil];

                [chatAlert show];
            }];
        }];

        [friendAlert bk_setCancelButtonWithTitle:NSLocalizedString(@"No", @"Friends") handler:^{
            [tableView setEditing:NO animated:YES];
        }];

        [friendAlert show];
    }
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

    [[ToxManager sharedInstance] chatWithToxFriend:friend completionBlock:^(CDChat *chat) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

        [delegate switchToChatsTabAndShowChatViewControllerWithChat:chat];
    }];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ToxFriend *friend = [self.friendsContainer friendAtIndex:indexPath.row];

    FriendCardViewController *fcvc = [[FriendCardViewController alloc] initWithToxFriend:friend];
    [self.navigationController pushViewController:fcvc animated:YES];
}

#pragma mark -  FriendsFilterViewDelegate

- (void)friendsFilterView:(FriendsFilterView *)view didSelectStringAtIndex:(NSUInteger)index
{
    [self hideFilterView];

    ToxFriendsContainerSort newSort = ToxFriendsContainerSortByName;

    if (index == 0) {
        newSort = ToxFriendsContainerSortByName;
    }
    else if (index == 1) {
        newSort = ToxFriendsContainerSortByStatus;
    }

    if (newSort == self.friendsContainer.friendsSort) {
        return;
    }

    self.friendsContainer.friendsSort = newSort;
}

- (void)friendsFilterViewEmptySpacePressed:(FriendsFilterView *)view
{
    [self hideFilterView];
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

- (void)createTitleButton
{
    self.titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.titleButton.titleLabel.font = [AppearanceManager fontHelveticaNeueWithSize:18];
    [self.titleButton setTitle:self.title forState:UIControlStateNormal];
    [self.titleButton addTarget:self
                         action:@selector(titleButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];

    [self setTitleButtonImageToArrowIsTop:NO];

    [self.titleButton sizeToFit];

    self.titleButton.titleEdgeInsets = UIEdgeInsetsMake(
            0.0,
            - self.titleButton.imageView.frame.size.width - 10.0,
            0.0,
            self.titleButton.imageView.frame.size.width);

    self.titleButton.imageEdgeInsets = UIEdgeInsetsMake(
            0.0,
            self.titleButton.titleLabel.frame.size.width,
            0.0,
            - self.titleButton.titleLabel.frame.size.width);

    self.navigationItem.titleView = self.titleButton;
}

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

- (void)updateLeftBarButtonItem
{
    NSString *title = NSLocalizedString(@"Requests", @"Friends");

    NSUInteger number = [[ToxManager sharedInstance].friendsContainer numberOfNotSeenRequests];

    if (number) {
        title = [title stringByAppendingFormat:@" (%lu)", (unsigned long)number];
    }

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(requestsButtonPressed)];
}

- (void)setTitleButtonImageToArrowIsTop:(BOOL)isTop
{
    UIImage *image = isTop ?
        [UIImage imageNamed:@"friends-vc-arrow-up"] :
        [UIImage imageNamed:@"friends-vc-arrow-down"];

    [self.titleButton setImage:image forState:UIControlStateNormal];
}

- (void)showFilterView
{
    if (self.filterView) {
        return;
    }

    [self setTitleButtonImageToArrowIsTop:YES];

    self.filterView = [[FriendsFilterView alloc] initWithFrame:self.view.bounds stringsArray:@[
        NSLocalizedString(@"By name", @"Friends"),
        NSLocalizedString(@"By status", @"Friends"),
    ]];

    self.filterView.delegate = self;

    [self.view addSubview:self.filterView];

    const CGFloat originY = CGRectGetMaxY(self.navigationController.navigationBar.frame);

    CGRect frame = self.filterView.frame;
    frame.origin.y = originY - [self.filterView heightOfVisiblePart];
    self.filterView.frame = frame;

    frame.origin.y = originY;

    self.view.userInteractionEnabled = NO;

    [UIView animateWithDuration:0.3 animations:^{
        self.filterView.frame = frame;

    } completion:^(BOOL f) {
        self.view.userInteractionEnabled = YES;
    }];
}

- (void)hideFilterView
{
    if (! self.filterView) {
        return;
    }

    [self setTitleButtonImageToArrowIsTop:NO];

    self.view.userInteractionEnabled = NO;

    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.filterView.frame;
        frame.origin.y = - [self.filterView heightOfVisiblePart];
        self.filterView.frame = frame;

    } completion:^(BOOL f) {
        self.view.userInteractionEnabled = YES;

        [self.filterView removeFromSuperview];
        self.filterView = nil;
    }];

}

@end
