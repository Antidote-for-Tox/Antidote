//
//  FriendRequestViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 11.07.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import <Masonry/Masonry.h>

#import <objcTox/OCTManager.h>
#import <objcTox/OCTFriendRequest.h>
#import <objcTox/OCTSubmanagerFriends.h>

#import "FriendRequestViewController.h"
#import "AppearanceManager.h"
#import "UIViewController+Utilities.h"
#import "UIImage+Utilities.h"
#import "ValueViewWithTitle.h"
#import "ErrorHandler.h"
#import "RunningContext.h"

static const CGFloat kHorizontalIndentation = 10.0;
static const CGFloat kVerticalIndentation = 20.0;

static const CGFloat kButtonHeight = 40.0;
static const CGFloat kButtonWidth = 120.0;

@interface FriendRequestViewController ()

@property (strong, nonatomic) ValueViewWithTitle *toxIdValueView;
@property (strong, nonatomic) ValueViewWithTitle *messageValueView;
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

    [self createValueViews];
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
        [[RunningContext context].toxManager.friends removeFriendRequest:self.request];

        [self.delegate friendRequestViewControllerRemovedRequest:self];
        [self.navigationController popViewControllerAnimated:YES];
    }];

    [sheet bk_setCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Friend requests") handler:nil];

    [sheet showInView:self.view];
}

- (void)acceptButtonPressed
{
    NSError *error;
    BOOL result = [[RunningContext context].toxManager.friends approveFriendRequest:self.request
                                                                              error:&error];

    if (! result) {
        [[AppContext sharedContext].errorHandler handleError:error type:ErrorHandlerTypeApproveFriendRequest];
        return;
    }

    [self.delegate friendRequestViewControllerAcceptedRequest:self];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -  Private

- (void)createValueViews
{
    self.toxIdValueView = [ValueViewWithTitle new];
    self.toxIdValueView.title = NSLocalizedString(@"Tox ID", @"Friend request");
    self.toxIdValueView.value = self.request.publicKey;
    [self.view addSubview:self.toxIdValueView];

    self.messageValueView = [ValueViewWithTitle new];
    self.messageValueView.title = NSLocalizedString(@"Message", @"Friend request");
    self.messageValueView.value = self.request.message;
    [self.view addSubview:self.messageValueView];
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
    [self.toxIdValueView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(kVerticalIndentation);
        make.left.equalTo(kHorizontalIndentation);
        make.right.equalTo(-kHorizontalIndentation);
    }];

    [self.messageValueView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toxIdValueView.bottom).offset(kVerticalIndentation);
        make.left.equalTo(kHorizontalIndentation);
        make.right.equalTo(-kHorizontalIndentation);
    }];

    [self.buttonsContainer makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageValueView.bottom).offset(kVerticalIndentation);
        make.centerX.equalTo(self.view);
        make.bottom.lessThanOrEqualTo(self.view).offset(-kVerticalIndentation);
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
