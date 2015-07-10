//
//  ToxListener.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 28.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ToxListener.h"
#import "OCTManager.h"
#import "NotificationManager.h"
#import "Helper.h"
#import "RBQFetchedResultsController.h"
#import "UpdatesQueue.h"
#import "AppDelegate+Utilities.h"
#import "NotificationObject.h"
#import "OCTFriendRequest.h"
#import "OCTMessageAbstract.h"
#import "OCTMessageText.h"
#import "OCTMessageFile.h"
#import "AvatarsManager.h"
#import "ChatViewController.h"
#import "TabBarViewController.h"

NSString *const kToxListenerGroupIdentifierFriendRequest = @"kToxListenerGroupIdentifierFriendRequest";

@interface ToxListener () <OCTSubmanagerUserDelegate, RBQFetchedResultsControllerDelegate>

@property (weak, nonatomic) OCTManager *manager;

@property (strong, nonatomic) RBQFetchedResultsController *friendRequestsController;
@property (strong, nonatomic) RBQFetchedResultsController *chatsController;
@property (strong, nonatomic) RBQFetchedResultsController *messagesController;

@property (strong, nonatomic) UpdatesQueue *friendRequestsUpdateQueue;
@property (strong, nonatomic) UpdatesQueue *messagesUpdateQueue;

@end

@implementation ToxListener

#pragma mark -  Lifecycle

- (instancetype)initWithManager:(OCTManager *)manager
{
    self = [super init];

    if (! self) {
        return nil;
    }

    _manager = manager;
    _manager.user.delegate = self;

    self.friendRequestsController = [self createFetchedResultsControllerForType:OCTFetchRequestTypeFriendRequest
                                                                        manager:manager];
    self.chatsController = [self createFetchedResultsControllerForType:OCTFetchRequestTypeChat manager:manager];
    self.messagesController = [self createFetchedResultsControllerForType:OCTFetchRequestTypeMessageAbstract
                                                                  manager:manager];

    return self;
}

#pragma mark -  Public

- (void)performUpdates
{
    [self updateConnectionStatus:self.manager.user.connectionStatus];
    [self updateFriendsBadge];
    [self updateChatBadge];
}

#pragma mark -  OCTSubmanagerUserDelegate

- (void)OCTSubmanagerUser:(OCTSubmanagerUser *)submanager connectionStatusUpdate:(OCTToxConnectionStatus)connectionStatus
{
    [self updateConnectionStatus:connectionStatus];
}

#pragma mark -  RBQFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(RBQFetchedResultsController *)controller
{
    if ([controller isEqual:self.friendRequestsController]) {
        self.friendRequestsUpdateQueue = [UpdatesQueue new];
    }
    else if ([controller isEqual:self.messagesController]) {
        self.messagesUpdateQueue = [UpdatesQueue new];
    }
}

- (void) controller:(RBQFetchedResultsController *)controller
    didChangeObject:(RBQSafeRealmObject *)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type != NSFetchedResultsChangeInsert) {
        return;
    }

    if ([controller isEqual:self.friendRequestsController]) {
        [self.friendRequestsUpdateQueue enqueuePath:newIndexPath type:UpdatesQueueObjectTypeInsert];
    }
    else if ([controller isEqual:self.messagesController]) {
        [self.messagesUpdateQueue enqueuePath:newIndexPath type:UpdatesQueueObjectTypeInsert];
    }
}

- (void)controllerDidChangeContent:(RBQFetchedResultsController *)controller
{
    if ([controller isEqual:self.friendRequestsController]) {
        [self didChangeFriendRequests];
    }
    else if ([controller isEqual:self.chatsController]) {
        [self didChangeChats];
    }
    else if ([controller isEqual:self.messagesController]) {
        [self didChangeMessages];
    }
}

#pragma mark -  Private

- (RBQFetchedResultsController *)createFetchedResultsControllerForType:(OCTFetchRequestType)type
                                                               manager:(OCTManager *)manager
{
    RBQFetchRequest *fetchRequest = [manager.objects fetchRequestForType:type withPredicate:nil];
    RBQFetchedResultsController *controller = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                     sectionNameKeyPath:nil
                                                                                              cacheName:nil];
    controller.delegate = self;
    [controller performFetch];

    return controller;
}

- (NotificationObject *)friendRequestNotificationWithPath:(NSIndexPath *)path
{
    OCTFriendRequest *request = [self.friendRequestsController objectAtIndexPath:path];

    NotificationObject *object = [NotificationObject new];
    object.topText = NSLocalizedString(@"Incoming friend request", @"Notifications");
    object.bottomText = request.message;
    object.groupIdentifier = kToxListenerGroupIdentifierFriendRequest;
    object.tapHandler = ^(NotificationObject *theObject) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate switchToFriendsTabAndShowFriendRequests];
    };

    return object;
}

- (NotificationObject *)messageNotificationWithPath:(NSIndexPath *)path
{
    OCTMessageAbstract *message = [self.messagesController objectAtIndexPath:path];

    if (! [self shouldShowNotificationForMessage:message]) {
        return nil;
    }

    NotificationObject *object = [NotificationObject new];
    object.image = [[AppContext sharedContext].avatars avatarFromString:message.sender.nickname
                                                               diameter:kNotificationObjectImageSize];
    object.topText = message.sender.nickname;
    object.groupIdentifier = message.chat.uniqueIdentifier;
    object.tapHandler = ^(NotificationObject *theObject) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate switchToChatsTabAndShowChatViewControllerWithChat:message.chat];
    };

    if (message.messageText) {
        object.bottomText = message.messageText.text;
    }
    else if (message.messageFile) {
        object.bottomText = NSLocalizedString(@"Incoming file", @"Notifications");
    }

    return object;
}

- (BOOL)shouldShowNotificationForMessage:(OCTMessageAbstract *)message
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *visibleVC = [delegate visibleViewController];

    if (! [visibleVC isKindOfClass:[ChatViewController class]]) {
        return YES;
    }

    ChatViewController *chatVC = (ChatViewController *)visibleVC;

    if ([chatVC.chat isEqual:message.chat]) {
        return NO;
    }

    return YES;
}

- (void)didChangeFriendRequests
{
    [self updateFriendsBadge];

    while (YES) {
        UpdatesQueue *queue = self.friendRequestsUpdateQueue;

        UpdatesQueueObject *object = [queue dequeue];
        if (! object) {
            break;
        }

        NotificationObject *notification = [self friendRequestNotificationWithPath:object.path];

        if (notification) {
            [[AppContext sharedContext].notification addNotificationToQueue:notification];
        }
    }
}

- (void)didChangeChats
{
    [self updateChatBadge];
}

- (void)didChangeMessages
{
    while (YES) {
        UpdatesQueue *queue = self.messagesUpdateQueue;

        UpdatesQueueObject *object = [queue dequeue];
        if (! object) {
            break;
        }

        NotificationObject *notification = [self messageNotificationWithPath:object.path];

        if (notification) {
            [[AppContext sharedContext].notification addNotificationToQueue:notification];
        }
    }
}

- (void)updateConnectionStatus:(OCTToxConnectionStatus)connectionStatus
{
    if (connectionStatus == OCTToxConnectionStatusNone) {
        [[AppContext sharedContext].notification showConnectingView];
    }
    else {
        [[AppContext sharedContext].notification hideConnectingView];
    }

    OCTToxUserStatus userStatus = self.manager.user.userStatus;
    [AppContext sharedContext].tabBarController.connectionStatus = [Helper circleStatusFromConnectionStatus:connectionStatus
                                                                                                 userStatus:userStatus];
}

- (void)updateFriendsBadge
{
    NSUInteger number = [self.friendRequestsController numberOfRowsForSectionIndex:0];
    NSString *badge = (number > 0) ? [NSString stringWithFormat : @"%lu", number] : nil;

    [[AppContext sharedContext].tabBarController setBadge:badge atIndex:TabBarViewControllerIndexFriends];
}

- (void)updateChatBadge
{
    NSInteger number = 0;
    for (OCTChat *chat in self.chatsController.fetchedObjects) {
        if ([chat hasUnreadMessages]) {
            number++;
        }
    }

    NSString *badge = (number > 0) ? [NSString stringWithFormat : @"%lu", number] : nil;

    [[AppContext sharedContext].tabBarController setBadge:badge atIndex:TabBarViewControllerIndexChats];
}

@end
