//
//  FriendCardViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 02.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "FriendCardViewController.h"
#import "UIViewController+Utilities.h"
#import "UIView+Utilities.h"

@interface FriendCardViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UITextField *nicknameField;
@property (strong, nonatomic) UILabel *realNameLabel;

@property (strong, nonatomic) OCTFriend *friend;

@end

@implementation FriendCardViewController

#pragma mark -  Lifecycle

- (instancetype)initWithToxFriend:(OCTFriend *)friend
{
    self = [super init];

    if (self) {
        self.friend = friend;

        // FIXME notification
        // [[NSNotificationCenter defaultCenter] addObserver:self
        //                                          selector:@selector(friendUpdateNotification:)
        //                                              name:kToxFriendsContainerUpdateSpecificFriendNotification
        //                                            object:nil];
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

    [self createScrollView];
    [self createNameViews];

    [self redrawTitleAndViews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self adjustSubviews];
}

#pragma mark -  UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.nicknameField]) {
        [textField resignFirstResponder];
    }

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.nicknameField]) {
        // FIXME nickname
        // [[ToxManager sharedInstance] changeNicknameTo:textField.text forFriend:self.friend];
    }
}

#pragma mark -  Notifications

// FIXME notification
// - (void)friendUpdateNotification:(NSNotification *)notification
// {
//     ToxFriend *updatedFriend = notification.userInfo[kToxFriendsContainerUpdateKeyFriend];

//     if (! [self.friend isEqual:updatedFriend]) {
//         return;
//     }

//     self.friend = updatedFriend;
//     [self redrawTitleAndViews];
// }

#pragma mark -  Private

- (void)createScrollView
{
    self.scrollView = [UIScrollView new];
    [self.view addSubview:self.scrollView];
}

- (void)createNameViews
{
    self.nicknameField = [UITextField new];
    self.nicknameField.delegate = self;
    self.nicknameField.placeholder = NSLocalizedString(@"Name", @"Settings");
    self.nicknameField.borderStyle = UITextBorderStyleRoundedRect;
    self.nicknameField.returnKeyType = UIReturnKeyDone;
    self.nicknameField.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:self.nicknameField];

    self.realNameLabel = [self.scrollView addLabelWithTextColor:[UIColor lightGrayColor]
                                                        bgColor:[UIColor clearColor]];
}

- (void)adjustSubviews
{
    self.scrollView.frame = self.view.bounds;

    CGFloat currentOriginY = 0.0;
    const CGFloat yIndentation = 10.0;

    CGRect frame = CGRectZero;

    {
        frame = self.nicknameField.frame;
        frame.size.width = 200.0;
        frame.size.height = 30.0;
        frame.origin.x = (self.view.bounds.size.width - frame.size.width) / 2;
        frame.origin.y = currentOriginY + yIndentation;

        self.nicknameField.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    {
        [self.realNameLabel sizeToFit];
        frame = self.realNameLabel.frame;
        frame.origin.x = (self.view.bounds.size.width - frame.size.width) / 2;
        frame.origin.y = currentOriginY + yIndentation;
        self.realNameLabel.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.origin.x, currentOriginY + yIndentation);
}

- (void)redrawTitleAndViews
{
    // FIXME nickname
    // self.title = self.friend.nickname;
    self.title = self.friend.name;

    // FIXME nickname
    // self.nicknameField.text = self.friend.nickname;

    self.realNameLabel.text = self.friend.name.length ?  [NSString stringWithFormat:@"(%@)", self.friend.name] : nil;

    [self adjustSubviews];
}

@end
