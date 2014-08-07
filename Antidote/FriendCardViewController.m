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
#import "ToxManager.h"

@interface FriendCardViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UITextField *associatedNameField;
@property (strong, nonatomic) UILabel *realNameLabel;

@property (strong, nonatomic) ToxFriend *friend;

@end

@implementation FriendCardViewController

#pragma mark -  Lifecycle

- (instancetype)initWithToxFriend:(ToxFriend *)friend;
{
    self = [super init];

    if (self) {
        self.friend = friend;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(friendUpdateNotification:)
                                                     name:kToxFriendsContainerUpdateSpecificFriendNotification
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
    if ([textField isEqual:self.associatedNameField]) {
        [textField resignFirstResponder];

        [[ToxManager sharedInstance] changeAssociatedNameTo:textField.text forFriend:self.friend];
    }

    return YES;
}

#pragma mark -  Notifications

- (void)friendUpdateNotification:(NSNotification *)notification
{
    ToxFriend *updatedFriend = notification.userInfo[kToxFriendsContainerUpdateKeyFriend];

    if (! [self.friend isEqual:updatedFriend]) {
        return;
    }

    self.friend = updatedFriend;
    [self redrawTitleAndViews];
}

#pragma mark -  Private

- (void)createScrollView
{
    self.scrollView = [UIScrollView new];
    [self.view addSubview:self.scrollView];
}

- (void)createNameViews
{
    self.associatedNameField = [UITextField new];
    self.associatedNameField.delegate = self;
    self.associatedNameField.placeholder = NSLocalizedString(@"Name", @"Settings");
    self.associatedNameField.borderStyle = UITextBorderStyleRoundedRect;
    self.associatedNameField.returnKeyType = UIReturnKeyDone;
    self.associatedNameField.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:self.associatedNameField];

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
        frame = self.associatedNameField.frame;
        frame.size.width = 200.0;
        frame.size.height = 30.0;
        frame.origin.x = (self.view.bounds.size.width - frame.size.width) / 2;
        frame.origin.y = currentOriginY + yIndentation;

        self.associatedNameField.frame = frame;
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
    self.title = self.friend.associatedName;

    self.associatedNameField.text = self.friend.associatedName;

    self.realNameLabel.text = self.friend.realName.length ?
        [NSString stringWithFormat:@"(%@)", self.friend.realName] : nil;

    [self adjustSubviews];
}

@end
