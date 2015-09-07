//
//  AllChatsViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <BlocksKit/NSArray+BlocksKit.h>

#import <objcTox/OCTMessageAbstract.h>
#import <objcTox/OCTMessageFile.h>
#import <objcTox/OCTMessageText.h>
#import <objcTox/OCTSubmanagerChats.h>

#import "AllChatsViewController.h"
#import "AllChatsCell.h"
#import "UIViewController+Utilities.h"
#import "ChatViewController.h"
#import "UIImage+Utilities.h"
#import "UIColor+Utilities.h"
#import "TimeFormatter.h"
#import "UITableViewCell+Utilities.h"
#import "AppearanceManager.h"
#import "Helper.h"
#import "AvatarsManager.h"
#import "RunningContext.h"

@interface AllChatsViewController () <UITableViewDataSource, UITableViewDelegate, RBQFetchedResultsControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) RBQFetchedResultsController *chatsController;
@property (strong, nonatomic) RBQFetchedResultsController *friendsController;

@end

@implementation AllChatsViewController

#pragma mark -  Lifecycle

- (id)init
{
    self = [super init];

    if (self) {
        self.title = NSLocalizedString(@"Chats", @"Chats");
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

    NSArray *descriptors = @[
        [RLMSortDescriptor sortDescriptorWithProperty:@"lastActivityDateInterval" ascending:NO],
    ];

    self.chatsController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeChat
                                                               predicate:nil
                                                         sortDescriptors:descriptors
                                                                delegate:self];
    self.friendsController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeFriend delegate:self];
    [self.tableView reloadData];
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

    OCTChat *chat = [self.chatsController objectAtIndexPath:indexPath];
    OCTFriend *friend = [chat.friends lastObject];

    cell.textLabel.text = friend.nickname;
    cell.imageView.image = [[AppContext sharedContext].avatars avatarFromString:friend.nickname
                                                                       diameter:cell.imageView.frame.size.width];
    cell.status = [Helper circleStatusFromFriend:friend];

    NSString *message = @"";
    NSString *dateString = [[TimeFormatter sharedInstance] stringFromDate:[chat lastActivityDate]
                                                                     type:TimeFormatterTypeRelativeDateAndTime];

    if (chat.lastMessage.messageText) {
        message = chat.lastMessage.messageText.text;
    }
    else if (chat.lastMessage.messageFile) {
        NSString *format;

        if ([chat.lastMessage isOutgoing]) {
            format = NSLocalizedString(@"Outgoing file: %@", @"Chats");
        }
        else {
            format = NSLocalizedString(@"Incoming file: %@", @"Chats");
        }

        message = [NSString stringWithFormat:format, chat.lastMessage.messageFile.fileName];
    }

    [cell setMessage:message andDate:dateString];

    cell.backgroundColor = [chat hasUnreadMessages] ?
                           [[AppContext sharedContext].appearance unreadChatCellBackground] :
                           [UIColor whiteColor];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chatsController numberOfRowsForSectionIndex:section];
}

- (void)     tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        weakself;

        NSString *title = NSLocalizedString(@"Are you sure you want to delete chat with all messages?", @"Chats");
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:title];

        [alert bk_addButtonWithTitle:NSLocalizedString(@"Yes", @"Chats") handler:^{
            strongself;

            OCTChat *chat = [self.chatsController objectAtIndexPath:indexPath];
            [[RunningContext context].toxManager.chats removeChatWithAllMessages:chat];
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

    OCTChat *chat = [self.chatsController objectAtIndexPath:indexPath];

    ChatViewController *cvc = [[ChatViewController alloc] initWithChat:chat];

    [self.navigationController pushViewController:cvc animated:YES];
}

#pragma mark -  RBQFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(RBQFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void) controller:(RBQFetchedResultsController *)controller
    didChangeObject:(RBQSafeRealmObject *)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(RBQFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    if ([controller isEqual:self.chatsController]) {
        switch (type) {
            case RBQFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case RBQFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case RBQFetchedResultsChangeUpdate:
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case RBQFetchedResultsChangeMove:
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
        }
    }
    else if ([controller isEqual:self.friendsController]) {
        if (type != RBQFetchedResultsChangeUpdate) {
            return;
        }

        OCTFriend *updatedFriend = (OCTFriend *)[anObject RLMObject];

        weakself;
        NSArray *pathsToUpdate = [[self.tableView indexPathsForVisibleRows] bk_select:^BOOL (NSIndexPath *path) {
            strongself;
            OCTChat *chat = [self.chatsController objectAtIndexPath:path];

            return ([chat.friends indexOfObject:updatedFriend] != NSNotFound);
        }];

        [self.tableView reloadRowsAtIndexPaths:pathsToUpdate withRowAnimation:UITableViewRowAnimationAutomatic];
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

#pragma mark -  Private

- (void)createTableView
{
    self.tableView = [UITableView new];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[AllChatsCell class] forCellReuseIdentifier:[AllChatsCell reuseIdentifier]];
    [self.view addSubview:self.tableView];
}

- (void)adjustSubviews
{
    self.tableView.frame = self.view.bounds;
}

@end
