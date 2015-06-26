//
//  ChatViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 10.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <JSQMessagesViewController/JSQMessages.h>

#import "ChatViewController.h"
#import "OCTFriend.h"
#import "StatusCircleView.h"
#import "Helper.h"
#import "UIView+Utilities.h"
#import "ProfileManager.h"
#import "TimeFormatter.h"
#import "OCTMessageAbstract.h"
#import "OCTMessageText.h"
#import "ChatMessage.h"
#import "AppearanceManager.h"

NSString *const kChatViewControllerUserIdentifier = @"user";

@interface ChatViewController () <RBQFetchedResultsControllerDelegate>

@property (strong, nonatomic, readwrite) OCTChat *chat;
@property (strong, nonatomic) OCTFriend *friend;

@property (strong, nonatomic) RBQFetchedResultsController *messagesController;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubble;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubble;

@property (strong, nonatomic) NSMutableArray *pathsToInsert;
@property (strong, nonatomic) NSMutableArray *pathsToDelete;
@property (strong, nonatomic) NSMutableArray *pathsToUpdate;

@end

@implementation ChatViewController

#pragma mark -  Lifecycle

- (instancetype)initWithChat:(OCTChat *)chat
{
    self = [super init];

    if (! self) {
        return nil;
    }

    self.hidesBottomBarWhenPushed = YES;

    self.senderId = @"user";
    self.senderDisplayName = @"user";

    self.chat = chat;
    self.friend = [chat.friends lastObject];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chat.uniqueIdentifier == %@", chat.uniqueIdentifier];
    self.messagesController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeMessageAbstract
                                                                  predicate:predicate
                                                                   delegate:self];

    [self createBubbleImages];
    [self updateTitleView];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateLastReadDate];

    // no files for now
    self.inputToolbar.contentView.leftBarButtonItem = nil;

    self.inputToolbar.contentView.textView.text = self.chat.enteredText;
    [self.inputToolbar toggleSendButtonEnabled];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    NSString *text = self.inputToolbar.contentView.textView.text;

    OCTSubmanagerObjects *submanager = [AppContext sharedContext].profileManager.toxManager.objects;
    [submanager changeChat:self.chat enteredText:text];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.inputToolbar.contentView.textView.text.length) {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
    }
}

#pragma mark -  Override

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date

{
    [[AppContext sharedContext].profileManager.toxManager.chats sendMessageToChat:self.chat
                                                                             text:text
                                                                             type:OCTToxMessageTypeNormal
                                                                            error:nil];
    // [self finishSendingMessageAnimated:YES];
}

#pragma mark -  RBQFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(RBQFetchedResultsController *)controller
{
    self.pathsToInsert = [NSMutableArray new];
    self.pathsToDelete = [NSMutableArray new];
    self.pathsToUpdate = [NSMutableArray new];
}

- (void) controller:(RBQFetchedResultsController *)controller
    didChangeObject:(RBQSafeRealmObject *)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.pathsToInsert addObject:newIndexPath];
            break;
        case NSFetchedResultsChangeDelete:
            [self.pathsToDelete addObject:indexPath];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.pathsToUpdate addObject:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [self.pathsToDelete addObject:indexPath];
            [self.pathsToInsert addObject:newIndexPath];
            break;
    }
}

- (void)controllerDidChangeContent:(RBQFetchedResultsController *)controller
{
    if (self.pathsToInsert.count == 1) {
        NSIndexPath *path = [self.pathsToInsert firstObject];
        NSInteger number = [self.messagesController numberOfRowsForSectionIndex:0];

        if (path.row == (number - 1)) {
            // Inserted new message
            [self.pathsToInsert removeObjectAtIndex:0];

            OCTMessageAbstract *message = [controller objectAtIndexPath:path];

            if ([message isOutgoing]) {
                [self finishSendingMessageAnimated:YES];
            }
            else {
                [self finishReceivingMessageAnimated:YES];
            }
        }
    }

    __weak ChatViewController *weakSelf = self;

    [self.collectionView performBatchUpdates:^{
        if (self.pathsToUpdate.count) {
            [weakSelf.collectionView reloadItemsAtIndexPaths:[self.pathsToUpdate copy]];
        }

        if (self.pathsToDelete.count) {
            [weakSelf.collectionView deleteItemsAtIndexPaths:[self.pathsToDelete copy]];
        }

        if (self.pathsToInsert.count) {
            [weakSelf.collectionView insertItemsAtIndexPaths:[self.pathsToInsert copy]];
        }
    } completion:nil];

    self.pathsToInsert = nil;
    self.pathsToDelete = nil;
    self.pathsToUpdate = nil;
}

#pragma mark -  JSQMessagesCollectionViewDataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView
       messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OCTMessageAbstract *message = [self.messagesController objectAtIndexPath:indexPath];

    return [[ChatMessage alloc] initWithMessage:message];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OCTMessageAbstract *message = [self.messagesController objectAtIndexPath:indexPath];

    if ([message isOutgoing]) {
        return self.outgoingBubble;
    }

    return self.incomingBubble;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark -  UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messagesController numberOfRowsForSectionIndex:section];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)
                                          [super collectionView:collectionView cellForItemAtIndexPath:indexPath];

    cell.textView.textColor = [UIColor blackColor];

    return cell;
}

#pragma mark -  Private

- (void)createBubbleImages
{
    JSQMessagesBubbleImageFactory *bubbleFactory = [JSQMessagesBubbleImageFactory new];

    UIColor *incoming = [[AppContext sharedContext].appearance bubbleIncomingColor];
    UIColor *outgoing = [[AppContext sharedContext].appearance bubbleOutgoingColor];

    self.incomingBubble = [bubbleFactory incomingMessagesBubbleImageWithColor:incoming];
    self.outgoingBubble = [bubbleFactory outgoingMessagesBubbleImageWithColor:outgoing];
}

- (void)updateTitleView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];

    UILabel *label = [view addLabelWithTextColor:[UIColor blackColor] bgColor:[UIColor clearColor]];
    label.text = self.friend.nickname;
    [label sizeToFit];

    StatusCircleView *statusView = [StatusCircleView new];
    statusView.status = [Helper circleStatusFromFriend:self.friend];
    [statusView redraw];
    [view addSubview:statusView];

    const CGFloat height = MAX(label.frame.size.height, statusView.frame.size.height);

    CGRect frame = label.frame;
    frame.origin.y = (height - frame.size.height) / 2;
    label.frame = frame;

    frame = statusView.frame;
    frame.origin.x = label.frame.size.width + 10.0;
    frame.origin.y = (height - frame.size.height) / 2;
    statusView.frame = frame;

    frame = CGRectZero;
    frame.size.height = height;
    frame.size.width = CGRectGetMaxX(statusView.frame);
    view.frame = frame;

    self.navigationItem.titleView = view;
}

- (void)updateLastReadDate
{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    [[AppContext sharedContext].profileManager.toxManager.objects changeChat:self.chat lastReadDateInterval:interval];
}

@end
