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
#import "ChatViewController.h"
#import "UIAlertView+BlocksKit.h"
#import "UIImage+Utilities.h"
#import "UIColor+Utilities.h"
#import "TimeFormatter.h"
#import "UITableViewCell+Utilities.h"
#import "ProfileManager.h"
#import "OCTMessageAbstract.h"
#import "OCTMessageText.h"
#import "OCTMessageFile.h"
#import "AppearanceManager.h"
#import "Helper.h"

@interface AllChatsViewController () <UITableViewDataSource, UITableViewDelegate, RBQFetchedResultsControllerDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) RBQFetchedResultsController *chatsController;

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

    self.chatsController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeChat delegate:self];
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
    // FIXME avatar
    // cell.imageView.image = [AvatarManager avatarInCurrentProfileWithClientId:friend.clientId
    //                                                 orCreateAvatarFromString:[friend nameToShow]
    //                                                                 withSide:cell.imageView.frame.size.width];
    cell.status = [Helper circleStatusFromFriend:friend];

    NSString *dateString = [[TimeFormatter sharedInstance] stringFromDate:chat.lastMessage.date
                                                                     type:TimeFormatterTypeRelativeDateAndTime];

    if ([chat.lastMessage isKindOfClass:[OCTMessageText class]]) {
        OCTMessageText *messageText = (OCTMessageText *)chat.lastMessage;

        [cell setMessage:messageText.text andDate:dateString];
    }
    else if ([chat.lastMessage isKindOfClass:[OCTMessageFile class]]) {
        NSString *format;

        if ([chat.lastMessage isOutgoing]) {
            format = NSLocalizedString(@"Outgoing file: %@", @"Chats");
        }
        else {
            format = NSLocalizedString(@"Incoming file: %@", @"Chats");
        }

        OCTMessageFile *messageFile = (OCTMessageFile *)chat.lastMessage;

        [cell setMessage:[NSString stringWithFormat:format, messageFile.fileName]
                 andDate:dateString];
    }

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
        __weak AllChatsViewController *weakSelf = self;

        NSString *title = NSLocalizedString(@"Are you sure you want to delete chat with all messages?", @"Chats");
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:title];

        [alert bk_addButtonWithTitle:NSLocalizedString(@"Yes", @"Chats") handler:^{
            OCTChat *chat = [weakSelf.chatsController objectAtIndexPath:indexPath];

            [[AppContext sharedContext].profileManager.toxManager.chats removeChatWithAllMessages:chat];
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
