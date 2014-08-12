//
//  AllChatsViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "AllChatsViewController.h"
#import "AllChatsCell.h"
#import "UIViewController+Utilities.h"
#import "CoreDataManager+Chat.h"
#import "CDMessage.h"
#import "CDUser.h"
#import "ChatViewController.h"
#import "UIAlertView+BlocksKit.h"
#import "ToxManager.h"
#import "UIImage+Utilities.h"
#import "AvatarFactory.h"
#import "UIColor+Utilities.h"
#import "Helper.h"
#import "TimeFormatter.h"

@interface AllChatsViewController () <UITableViewDataSource, UITableViewDelegate,
    NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation AllChatsViewController

#pragma mark -  Lifecycle

- (id)init
{
    self = [super init];

    if (self) {
        self.title = NSLocalizedString(@"Chats", @"Chats");

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(friendUpdateNotification:)
                                                     name:kToxFriendsContainerUpdateSpecificFriendNotification
                                                   object:nil];
    }

    return self;
}

- (void)loadView
{
    [self loadWhiteView];

    [self createTableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    __weak AllChatsViewController *weakSelf = self;

    [CoreDataManager allChatsFetchedControllerWithDelegate:self
                                           completionQueue:dispatch_get_main_queue()
                                           completionBlock:^(NSFetchedResultsController *controller)
    {
        weakSelf.fetchedResultsController = controller;
        [weakSelf.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // in case if someone was renamed, etc.
    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self adjustSubviews];
}

#pragma mark -  UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AllChatsCell *cell = [tableView dequeueReusableCellWithIdentifier:[AllChatsCell reuseIdentifier]
                                                         forIndexPath:indexPath];

    CDChat *chat = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ToxFriend *friend = [self friendForIndexPath:indexPath];

    NSString *usersString;
    for (CDUser *user in chat.users) {
        ToxFriend *friend = [[ToxManager sharedInstance].friendsContainer friendWithClientId:user.clientId];

        NSString *name = [friend nameToShow];

        if (usersString) {
            usersString = [usersString stringByAppendingFormat:@", %@", name];
        }
        else {
            usersString = name;
        }
    }

    cell.textLabel.text = usersString;
    cell.imageView.image = [AvatarFactory avatarFromString:usersString side:cell.imageView.frame.size.width];
    cell.status = [Helper toxFriendStatusToCircleStatus:friend.status];

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:chat.lastMessage.date];

    [cell setMessage:chat.lastMessage.text
             andDate:[[TimeFormatter sharedInstance] stringFromDate:date type:TimeFormatterTypeRelativeDateAndTime]];

    cell.backgroundColor = (chat.lastMessage.date < chat.lastReadDate) ? [UIColor whiteColor] :
        [AppearanceManager unreadChatCellBackground];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> info = self.fetchedResultsController.sections[section];

    return info.numberOfObjects;
}

- (void)  tableView:(UITableView *)tableView
 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
  forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __weak AllChatsViewController *weakSelf = self;

        NSString *title = NSLocalizedString(@"Are you sure you want to delete chat with all messages?", @"Chats");
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:title];

        [alert bk_addButtonWithTitle:NSLocalizedString(@"Yes", @"Chats") handler:^{
            CDChat *chat = [weakSelf.fetchedResultsController objectAtIndexPath:indexPath];

            [CoreDataManager removeChatWithAllMessages:chat completionQueue:nil completionBlock:nil];
        }];

        [alert bk_setCancelButtonWithTitle:NSLocalizedString(@"No", @"Chats") handler:^{
            [tableView setEditing:NO animated:YES];
        }];

        [alert show];
    }
}

#pragma mark -  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [AllChatsCell height];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CDChat *chat = [self.fetchedResultsController objectAtIndexPath:indexPath];

    ChatViewController *cvc = [[ChatViewController alloc] initWithChat:chat];

    [self.navigationController pushViewController:cvc animated:YES];
}

#pragma mark -  NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert) {
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeDelete) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeMove) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeUpdate) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark -  Notifications

- (void)friendUpdateNotification:(NSNotification *)notification
{
    ToxFriend *updatedFriend = notification.userInfo[kToxFriendsContainerUpdateKeyFriend];

    for (NSIndexPath *path in self.tableView.indexPathsForVisibleRows) {
        ToxFriend *friend = [self friendForIndexPath:path];

        if ([friend isEqual:updatedFriend]) {
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
            return;
        }
    }
}

#pragma mark -  Private

- (void)createTableView
{
    self.tableView = [UITableView new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];

    [self.tableView registerClass:[AllChatsCell class] forCellReuseIdentifier:[AllChatsCell reuseIdentifier]];

    [self.view addSubview:self.tableView];
}

- (void)adjustSubviews
{
    self.tableView.frame = self.view.bounds;
}

- (ToxFriend *)friendForIndexPath:(NSIndexPath *)path
{
    CDChat *chat = [self.fetchedResultsController objectAtIndexPath:path];
    CDUser *user = [chat.users anyObject];

    return [[ToxManager sharedInstance].friendsContainer friendWithClientId:user.clientId];
}

@end
