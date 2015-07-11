//
//  FriendRequestViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 11.07.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import <Masonry/Masonry.h>

#import "FriendRequestViewController.h"
#import "OCTFriendRequest.h"
#import "AppearanceManager.h"
#import "UIViewController+Utilities.h"
#import "ProfileManager.h"
#import "UIImage+Utilities.h"

static const CGFloat kHorizontalIndentation = 10.0;
static const CGFloat kVerticalSmallIndentation = 4.0;
static const CGFloat kVerticalLargeIndentation = 20.0;

static const CGFloat kTextIndentation = 8.0;

static const CGFloat kButtonHeight = 40.0;
static const CGFloat kButtonWidth = 120.0;

@interface FriendRequestViewController ()

@property (strong, nonatomic) UILabel *toxIdTitleLabel;
@property (strong, nonatomic) UIView *toxIdValueContainer;

@property (strong, nonatomic) UILabel *messageTitleLabel;
@property (strong, nonatomic) UIView *messageValueContainer;

@property (strong, nonatomic) UIView *buttonsContainer;
@property (strong, nonatomic) UILabel *orLabel;
@property (strong, nonatomic) UIButton *declineButton;
@property (strong, nonatomic) UIButton *acceptButton;

@property (strong, nonatomic) OCTFriendRequest *request;

@end

@implementation FriendRequestViewController

#pragma mark -  Lifecycle

- (instancetype)initWithRequest:(OCTFriendRequest *)request
{
    self = [super init];

    if (! self) {
        return nil;
    }

    self.title = NSLocalizedString(@"Friend request", @"Friend request");
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _request = request;

    return self;
}

- (void)loadView
{
    [self loadLightGrayView];

    [self createToxIdViews];
    [self createMessageViews];
    [self createButtons];

    [self installConstraints];
}

#pragma mark -  Properties

- (void)declineButtonPressed
{
    NSString *title = NSLocalizedString(@"Are you sure you want to decline friend request?", @"Friend requests");
    UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:title];

    weakself;

    [sheet bk_setDestructiveButtonWithTitle:NSLocalizedString(@"Decline", @"Friend requests") handler:^{
        strongself;
        [[AppContext sharedContext].profileManager.toxManager.friends removeFriendRequest:self.request];
        [self.navigationController popViewControllerAnimated:YES];
    }];

    [sheet bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Friend requests") handler:nil];

    [sheet showInView:self.view];
}

- (void)acceptButtonPressed
{
    [[AppContext sharedContext].profileManager.toxManager.friends approveFriendRequest:self.request error:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -  Private

- (void)createToxIdViews
{
    self.toxIdTitleLabel = [self createTitleLabelWithText:NSLocalizedString(@"Tox ID", @"Friend request")];
    [self.view addSubview:self.toxIdTitleLabel];

    self.toxIdValueContainer = [self createViewWithText:self.request.publicKey];
    [self.view addSubview:self.toxIdValueContainer];
}

- (void)createMessageViews
{
    self.messageTitleLabel = [self createTitleLabelWithText:NSLocalizedString(@"Message", @"Friend request")];
    [self.view addSubview:self.messageTitleLabel];

    self.messageValueContainer = [self createViewWithText:self.request.message];
    [self.view addSubview:self.messageValueContainer];
}

- (void)createButtons
{
    self.buttonsContainer = [UIView new];
    self.buttonsContainer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.buttonsContainer];

    self.declineButton = [self createButtonWithText:NSLocalizedString(@"Decline", @"Friend request")
                                         titleColor:[UIColor blackColor]
                                    backgroundColor:[UIColor whiteColor]
                                             action:@selector(declineButtonPressed)];
    [self.buttonsContainer addSubview:self.declineButton];

    self.acceptButton = [self createButtonWithText:NSLocalizedString(@"Accept", @"Friend request")
                                        titleColor:[UIColor whiteColor]
                                   backgroundColor:[[AppContext sharedContext].appearance textMainColor]
                                            action:@selector(acceptButtonPressed)];
    [self.buttonsContainer addSubview:self.acceptButton];

    self.orLabel = [UILabel new];
    self.orLabel.text = NSLocalizedString(@"or", @"Friend request");
    self.orLabel.textColor = [UIColor blackColor];
    self.orLabel.backgroundColor = [UIColor clearColor];
    [self.buttonsContainer addSubview:self.orLabel];
}

- (UILabel *)createTitleLabelWithText:(NSString *)text
{
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];

    return label;
}

- (UIView *)createViewWithText:(NSString *)text
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 5.0;
    view.layer.borderWidth = 0.5;
    view.layer.borderColor = [[UIColor colorWithWhite:0.8f alpha:1.0f] CGColor];
    view.layer.masksToBounds = YES;

    UILabel *label = [UILabel new];
    label.text = text;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.textColor = [UIColor blackColor];
    [view addSubview:label];

    [label makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(view).offset(kTextIndentation);
        make.bottom.right.equalTo(view).offset(-kTextIndentation);
    }];

    return view;
}

- (UIButton *)createButtonWithText:(NSString *)text
                        titleColor:(UIColor *)titleColor
                   backgroundColor:(UIColor *)backgroundColor
                            action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    button.layer.cornerRadius = 5.0;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];

    UIImage *bgImage = [UIImage imageWithColor:backgroundColor size:CGSizeMake(1.0, 1.0)];
    [button setBackgroundImage:bgImage forState:UIControlStateNormal];

    return button;
}

- (void)installConstraints
{
    [self.toxIdTitleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(kVerticalLargeIndentation);
        make.left.equalTo(kHorizontalIndentation);
        make.right.equalTo(-kHorizontalIndentation);
    }];

    [self.toxIdValueContainer makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toxIdTitleLabel.bottom).offset(kVerticalSmallIndentation);
        make.left.equalTo(kHorizontalIndentation);
        make.right.equalTo(-kHorizontalIndentation);
    }];

    [self.messageTitleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toxIdValueContainer.bottom).offset(kVerticalLargeIndentation);
        make.left.equalTo(kHorizontalIndentation);
        make.right.equalTo(-kHorizontalIndentation);
    }];

    [self.messageValueContainer makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageTitleLabel.bottom).offset(kVerticalSmallIndentation);
        make.left.equalTo(kHorizontalIndentation);
        make.right.equalTo(-kHorizontalIndentation);
    }];

    [self.buttonsContainer makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageValueContainer.bottom).offset(kVerticalLargeIndentation);
        make.centerX.equalTo(self.view);
        make.bottom.lessThanOrEqualTo(self.view).offset(-kVerticalLargeIndentation);
        make.height.equalTo(kButtonHeight);
    }];

    [self.declineButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.equalTo(self.buttonsContainer);
        make.width.equalTo(kButtonWidth);
    }];

    [self.orLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.buttonsContainer);
        make.left.equalTo(self.declineButton.right).offset(kHorizontalIndentation);
    }];

    [self.acceptButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self.buttonsContainer);
        make.left.equalTo(self.orLabel.right).offset(kHorizontalIndentation);
        make.width.equalTo(kButtonWidth);
    }];
}

@end
