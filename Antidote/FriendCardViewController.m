//
//  FriendCardViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 02.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <BlocksKit/UIControl+BlocksKit.h>
#import <Masonry/Masonry.h>

#import "FriendCardViewController.h"
#import "UIViewController+Utilities.h"
#import "ProfileManager.h"
#import "Helper.h"
#import "ValueViewWithTitle.h"
#import "AvatarsManager.h"
#import "AppearanceManager.h"
#import "ChatViewController.h"
#import "TabBarViewController.h"

static const CGFloat kHorizontalIndentation = 10.0;
static const CGFloat kVerticalIndentation = 20.0;

static const CGFloat kAvatarSize = 120.0;
static const CGFloat kSeparatorHeight = 0.5;
static const CGFloat kButtonSize = 40.0;

@interface FriendCardViewController () <RBQFetchedResultsControllerDelegate>

@property (strong, nonatomic) OCTFriend *friend;
@property (strong, nonatomic) RBQFetchedResultsController *friendController;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UITextField *nicknameTextField;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UIView *separator;
@property (strong, nonatomic) ValueViewWithTitle *toxIdValueView;
@property (strong, nonatomic) UIView *buttonsView;
@property (strong, nonatomic) UIButton *chatButton;

@end

@implementation FriendCardViewController

#pragma mark -  Lifecycle

- (instancetype)initWithToxFriend:(OCTFriend *)friend
{
    self = [super init];

    if (self) {
        _friend = friend;

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier == %@", friend.uniqueIdentifier];
        _friendController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeFriend
                                                                predicate:predicate
                                                                 delegate:self];
    }
    return self;
}

- (void)loadView
{
    [self loadLightGrayView];

    [self createScrollView];
    [self createAvatarImageView];
    [self createNameViews];
    [self createSeparator];
    [self createToxIdView];
    [self createBottomButtons];

    [self installConstraints];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    self.scrollView.contentSize = self.contentView.frame.size;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self friendWasUpdated];
}

#pragma mark -  RBQFetchedResultsControllerDelegate

- (void) controller:(RBQFetchedResultsController *)controller
    didChangeObject:(RBQSafeRealmObject *)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    if (type == NSFetchedResultsChangeUpdate) {
        self.friend = [self.friendController objectAtIndexPath:indexPath];

        [self friendWasUpdated];
    }
}

#pragma mark -  Private

- (void)createScrollView
{
    self.scrollView = [UIScrollView new];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scrollView];

    self.contentView = [UIView new];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.contentView];
}

- (void)createAvatarImageView
{
    self.avatarImageView = [UIImageView new];
    self.avatarImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.avatarImageView];
}

- (void)createNameViews
{
    self.nicknameTextField = [UITextField new];
    self.nicknameTextField.text = self.friend.nickname;
    self.nicknameTextField.textColor = [[AppContext sharedContext].appearance textMainColor];
    self.nicknameTextField.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.nicknameTextField];

    self.nameLabel = [UILabel new];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textColor = [UIColor darkGrayColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.nameLabel];

    self.statusLabel = [UILabel new];
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.textColor = [UIColor darkGrayColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.numberOfLines = 3;
    [self.contentView addSubview:self.statusLabel];
}

- (void)createSeparator
{
    self.separator = [UIView new];
    self.separator.backgroundColor = [UIColor darkGrayColor];
    [self.contentView addSubview:self.separator];
}

- (void)createToxIdView
{
    self.toxIdValueView = [ValueViewWithTitle new];
    self.toxIdValueView.title = NSLocalizedString(@"Tox ID", @"Friend card");
    [self.contentView addSubview:self.toxIdValueView];
}

- (void)createBottomButtons
{
    self.buttonsView = [UIView new];
    self.buttonsView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.buttonsView];

    self.chatButton = [UIButton new];
    [self.chatButton setImage:[UIImage imageNamed:@"tab-bar-chats"] forState:UIControlStateNormal];
    [self.buttonsView addSubview:self.chatButton];

    weakself;
    [self.chatButton bk_addEventHandler:^(id button) {
        strongself;
        AppContext *context = [AppContext sharedContext];

        OCTChat *chat = [context.profileManager.toxManager.chats getOrCreateChatWithFriend:self.friend];
        ChatViewController *chatVC = [[ChatViewController alloc] initWithChat:chat];

        TabBarViewControllerIndex index = TabBarViewControllerIndexChats;
        context.tabBarController.selectedIndex = index;

        UINavigationController *navCon = [context.tabBarController navigationControllerForIndex:index];
        [navCon popToRootViewControllerAnimated:NO];
        [navCon pushViewController:chatVC animated:NO];
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)installConstraints
{
    [self.scrollView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.contentView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
    }];

    [self.avatarImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kVerticalIndentation);
        make.centerX.equalTo(self.contentView);
        make.width.height.equalTo(kAvatarSize);
    }];

    [self.nicknameTextField makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarImageView.bottom).offset(kVerticalIndentation);
        make.left.equalTo(self.contentView).offset(kHorizontalIndentation);
        make.right.equalTo(self.contentView).offset(-kHorizontalIndentation);
    }];

    [self.nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nicknameTextField.bottom);
        make.left.equalTo(self.contentView).offset(kHorizontalIndentation);
        make.right.equalTo(self.contentView).offset(-kHorizontalIndentation);
    }];

    [self.statusLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.bottom).offset(kVerticalIndentation);
        make.left.equalTo(self.contentView).offset(kHorizontalIndentation);
        make.right.equalTo(self.contentView).offset(-kHorizontalIndentation);
    }];

    [self.separator makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.statusLabel.bottom).offset(kVerticalIndentation);
        make.left.equalTo(self.contentView).offset(kHorizontalIndentation);
        make.right.equalTo(self.contentView).offset(-kHorizontalIndentation);
        make.height.equalTo(kSeparatorHeight);
    }];

    [self.toxIdValueView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.separator.bottom).offset(kVerticalIndentation);
        make.left.equalTo(self.contentView).offset(kHorizontalIndentation);
        make.right.equalTo(self.contentView).offset(-kHorizontalIndentation);
    }];

    [self.buttonsView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toxIdValueView.bottom).offset(kVerticalIndentation);
        make.bottom.equalTo(self.contentView).offset(-kVerticalIndentation);
        make.centerX.equalTo(self.contentView);
        make.height.equalTo(kButtonSize);
    }];

    [self.chatButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.buttonsView);
        make.centerY.equalTo(self.buttonsView);
        make.width.height.equalTo(kButtonSize);
    }];
}

- (void)friendWasUpdated
{
    self.title = self.friend.nickname;

    self.avatarImageView.image = [[AppContext sharedContext].avatars avatarFromString:self.friend.nickname
                                                                             diameter:kAvatarSize];
    self.statusLabel.text = self.friend.statusMessage;
    self.toxIdValueView.value = self.friend.publicKey;

    if (self.friend.name && ! [self.friend.name isEqualToString:self.friend.nickname]) {
        self.nameLabel.text = [NSString stringWithFormat:@"(%@)", self.friend.name];
    }
    else {
        self.nameLabel.text = nil;
    }
}

@end
