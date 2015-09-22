//
//  FriendCardViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 25/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import <objcTox/OCTSubmanagerChats.h>
#import <objcTox/OCTSubmanagerObjects.h>

#import "FriendCardViewController.h"
#import "ContentCellWithTitleImmutable.h"
#import "ContentCellWithTitleEditable.h"
#import "ContentSeparatorCell.h"
#import "ContentCellWithAvatar.h"
#import "Helper.h"
#import "UITableViewCell+Utilities.h"
#import "AvatarsManager.h"
#import "ChatViewController.h"
#import "TabBarViewController.h"
#import "RunningContext.h"

static const CGFloat kFooterHeight = 50.0;

typedef NS_ENUM(NSUInteger, CellType) {
    CellTypeSeparatorTransparent,
    CellTypeSeparatorGray,
    CellTypeAvatar,
    CellTypeNicknameImmutable,
    CellTypeNicknameEditable,
    CellTypeName,
    CellTypeStatusMessage,
    CellTypeToxId,
};

@interface FriendCardViewController () <ContentCellWithTitleImmutableDelegate, ContentCellWithTitleEditableDelegate,
                                        RBQFetchedResultsControllerDelegate>

@property (strong, nonatomic) OCTFriend *friend;
@property (strong, nonatomic) RBQFetchedResultsController *friendController;

@property (assign, nonatomic) BOOL ignoreNextFriendUpdate;

@end

@implementation FriendCardViewController

#pragma mark -  Lifecycle

- (instancetype)initWithToxFriend:(OCTFriend *)friend
{
    self = [super initWithTitle:friend.nickname tableStyle:UITableViewStylePlain tableStructure:@[
                @[
                    @(CellTypeSeparatorTransparent),
                    @(CellTypeAvatar),
                    @(CellTypeSeparatorGray),
                    @(CellTypeNicknameImmutable),
                    @(CellTypeName),
                    @(CellTypeStatusMessage),
                    @(CellTypeSeparatorGray),
                    @(CellTypeToxId),
                    @(CellTypeSeparatorGray),
                ]
            ]];

    if (! self) {
        return nil;
    }

    _friend = friend;

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier == %@", friend.uniqueIdentifier];
    _friendController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeFriend
                                                            predicate:predicate
                                                             delegate:self];

    return self;
}

#pragma mark -  Actions

- (void)chatButtonPressed
{
    OCTChat *chat = [[RunningContext context].toxManager.chats getOrCreateChatWithFriend:self.friend];
    ChatViewController *chatVC = [[ChatViewController alloc] initWithChat:chat];

    TabBarViewControllerIndex index = TabBarViewControllerIndexChats;
    [RunningContext context].tabBarController.selectedIndex = index;

    UINavigationController *navCon = [[RunningContext context].tabBarController navigationControllerForIndex:index];
    [navCon popToRootViewControllerAnimated:NO];
    [navCon pushViewController:chatVC animated:NO];
}

#pragma mark -  Override

- (void)configureTableView
{
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self createFooterView];
}

- (void)registerCellsForTableView
{
    [self.tableView registerClass:[ContentSeparatorCell class] forCellReuseIdentifier:[ContentSeparatorCell reuseIdentifier]];
    [self.tableView registerClass:[ContentCellWithAvatar class] forCellReuseIdentifier:[ContentCellWithAvatar reuseIdentifier]];
    [self.tableView registerClass:[ContentCellWithTitleImmutable class]
           forCellReuseIdentifier:[ContentCellWithTitleImmutable reuseIdentifier]];
    [self.tableView registerClass:[ContentCellWithTitleEditable class]
           forCellReuseIdentifier:[ContentCellWithTitleEditable reuseIdentifier]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];

    switch (type) {
        case CellTypeSeparatorTransparent:
            return [self separatorCellAtIndexPath:indexPath isGray:NO];
        case CellTypeSeparatorGray:
            return [self separatorCellAtIndexPath:indexPath isGray:YES];
        case CellTypeAvatar:
            return [self cellWithAvatarAtIndexPath:indexPath];
        case CellTypeNicknameImmutable:
            return [self cellWithNicknameAtIndexPath:indexPath editable:NO];
        case CellTypeNicknameEditable:
            return [self cellWithNicknameAtIndexPath:indexPath editable:YES];
        case CellTypeName:
            return [self cellWithNameAtIndexPath:indexPath];
        case CellTypeStatusMessage:
            return [self cellWithStatusMessageAtIndexPath:indexPath];
        case CellTypeToxId:
            return [self cellWithToxIdAtIndexPath:indexPath];
    }
}

#pragma mark -  ContentCellWithTitleImmutableDelegate

- (void)contentCellWithTitleImmutableEditButtonPressed:(ContentCellWithTitleImmutable *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CellType type = [self cellTypeForIndexPath:indexPath];

    NSMutableArray *arrayToChange = self.tableStructure[indexPath.section];

    if (type == CellTypeNicknameImmutable) {
        NSUInteger index = [arrayToChange indexOfObject:@(CellTypeNicknameImmutable)];
        [arrayToChange replaceObjectAtIndex:index withObject:@(CellTypeNicknameEditable)];
    }

    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

    ContentCellWithTitleEditable *editableCell = (ContentCellWithTitleEditable *)
                                                 [self.tableView cellForRowAtIndexPath:indexPath];
    [editableCell startEditing];
}

#pragma mark -  ContentCellWithTitleEditableDelegate

- (void)contentCellWithTitleEditableDidBeginEditing:(ContentCellWithTitleEditable *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)contentCellWithTitleEditableDidEndEditing:(ContentCellWithTitleEditable *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CellType type = [self cellTypeForIndexPath:indexPath];

    NSMutableArray *arrayToChange = self.tableStructure[indexPath.section];

    if (type == CellTypeNicknameEditable) {
        self.ignoreNextFriendUpdate = YES;

        [[RunningContext context].toxManager.objects changeFriend:self.friend nickname:cell.mainText];

        NSUInteger index = [arrayToChange indexOfObject:@(CellTypeNicknameEditable)];
        [arrayToChange replaceObjectAtIndex:index withObject:@(CellTypeNicknameImmutable)];

        // FIXME avatar
        // if (! [[ToxManager sharedInstance] userHasAvatar]) {
        [self reloadAvatarCell];
        // }
    }

    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)contentCellWithTitleEditableWantsToResize:(ContentCellWithTitleEditable *)cell
{
    // This forces tableView to nicely animate change of cell's frame without reloading it.
    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:YES];

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

#pragma mark -  RBQFetchedResultsControllerDelegate

- (void) controller:(RBQFetchedResultsController *)controller
    didChangeObject:(RBQSafeRealmObject *)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(RBQFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type != RBQFetchedResultsChangeUpdate) {
        return;
    }

    self.friend = [self.friendController objectAtIndexPath:indexPath];

    if (self.ignoreNextFriendUpdate) {
        self.ignoreNextFriendUpdate = NO;
    }

    // workaround for deadlock in objcTox https://github.com/Antidote-for-Tox/objcTox/issues/51
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0];
}

#pragma mark -  Private

- (void)createFooterView
{
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, kFooterHeight)];

    UIImage *image = [[UIImage imageNamed:@"friend-card-chat"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    UIButton *chatButton = [UIButton new];
    [chatButton setImage:image forState:UIControlStateNormal];
    [chatButton addTarget:self action:@selector(chatButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:chatButton];

    [chatButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(footer);
        make.centerX.equalTo(footer);
        make.size.equalTo(kFooterHeight);
    }];

    self.tableView.tableFooterView = footer;
}

- (ContentSeparatorCell *)separatorCellAtIndexPath:(NSIndexPath *)indexPath isGray:(BOOL)isGray
{
    ContentSeparatorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[ContentSeparatorCell reuseIdentifier]
                                                                      forIndexPath:indexPath];
    cell.showGraySeparator = isGray;

    return cell;
}

- (ContentCellWithAvatar *)cellWithAvatarAtIndexPath:(NSIndexPath *)indexPath
{
    ContentCellWithAvatar *cell = [self.tableView dequeueReusableCellWithIdentifier:[ContentCellWithAvatar reuseIdentifier]
                                                                       forIndexPath:indexPath];
    cell.avatar = [[AppContext sharedContext].avatars avatarFromString:self.friend.nickname
                                                              diameter:kContentCellWithAvatarImageSize];
    cell.userInteractionEnabled = NO;

    return cell;
}

- (ContentCellWithTitleBasic *)cellWithNicknameAtIndexPath:(NSIndexPath *)indexPath editable:(BOOL)editable
{
    NSString *identifier = editable ?
                           [ContentCellWithTitleEditable reuseIdentifier] :
                           [ContentCellWithTitleImmutable reuseIdentifier];

    ContentCellWithTitleBasic *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.title = NSLocalizedString(@"Nickname", @"Friend Card");
    cell.buttonTitle = nil;
    cell.mainText = self.friend.nickname;

    if (editable) {
        ContentCellWithTitleEditable *eCell = (ContentCellWithTitleEditable *)cell;
        eCell.maxMainTextLength = kOCTToxMaxNameLength;
    }
    else {
        ContentCellWithTitleImmutable *iCell = (ContentCellWithTitleImmutable *)cell;
        iCell.showEditButton = YES;
    }

    return cell;
}

- (ContentCellWithTitleImmutable *)cellWithNameAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [ContentCellWithTitleImmutable reuseIdentifier];

    ContentCellWithTitleImmutable *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.title = NSLocalizedString(@"Name", @"Friend Card");
    cell.buttonTitle = nil;
    cell.mainText = self.friend.name;
    cell.showEditButton = NO;

    return cell;
}

- (ContentCellWithTitleImmutable *)cellWithStatusMessageAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [ContentCellWithTitleImmutable reuseIdentifier];

    ContentCellWithTitleImmutable *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.title = NSLocalizedString(@"Status Message", @"Friend Card");
    cell.buttonTitle = nil;
    cell.mainText = self.friend.statusMessage;
    cell.showEditButton = NO;

    return cell;
}

- (ContentCellWithTitleImmutable *)cellWithToxIdAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [ContentCellWithTitleImmutable reuseIdentifier];
    ContentCellWithTitleImmutable *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.title = NSLocalizedString(@"Public Key", @"Friend Card");
    cell.buttonTitle = nil;
    cell.mainText = self.friend.publicKey;
    cell.showEditButton = NO;

    return cell;
}

- (void)reloadAvatarCell
{
    NSIndexPath *path = [self indexPathForCellType:CellTypeAvatar];
    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}

@end
