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
#import "OCTMessageText.h"
#import "OCTMessageFile.h"
#import "AppearanceManager.h"
#import "Helper.h"

@interface AllChatsViewController () <UITableViewDataSource, UITableViewDelegate, OCTArrayDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) OCTArray *allChats;

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
                                                     name:kProfileManagerFriendUpdateNotification
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

    self.allChats = [[AppContext sharedContext].profileManager.toxManager.chats allChats];
    self.allChats.delegate = self;
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

    OCTChat *chat = [self.allChats objectAtIndex:indexPath.row];
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

    cell.backgroundColor = [chat hasUnreadMessages] ? [UIColor whiteColor] :
        [[AppContext sharedContext].appearance unreadChatCellBackground];

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allChats.count;
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
            OCTChat *chat = [weakSelf.allChats objectAtIndex:indexPath.row];

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

    OCTChat *chat = [self.allChats objectAtIndex:indexPath.row];

    ChatViewController *cvc = [[ChatViewController alloc] initWithChat:chat];

    [self.navigationController pushViewController:cvc animated:YES];
}

#pragma mark -  OCTArrayDelegate

- (void)OCTArrayWasUpdated:(OCTArray *)array
{
    [self.tableView reloadData];
}

#pragma mark -  Notifications

- (void)friendUpdateNotification:(NSNotification *)notification
{
    OCTFriend *updatedFriend = notification.userInfo[kProfileManagerFriendUpdateKey];

    for (NSIndexPath *path in self.tableView.indexPathsForVisibleRows) {
        OCTChat *chat = [self.allChats objectAtIndex:path.row];
        OCTFriend *friend = [chat.friends lastObject];

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
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[AllChatsCell class] forCellReuseIdentifier:[AllChatsCell reuseIdentifier]];
    [self.view addSubview:self.tableView];
}

- (void)adjustSubviews
{
    self.tableView.frame = self.view.bounds;
}

@end
