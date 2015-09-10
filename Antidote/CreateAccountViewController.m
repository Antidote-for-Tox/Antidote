//
//  CreateAccountViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 09/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <objcTox/OCTManager.h>
#import <objcTox/OCTSubmanagerUser.h>
#import <objcTox/OCTToxConstants.h>

#import "CreateAccountViewController.h"
#import "UIViewController+Utilities.h"
#import "AppearanceManager.h"
#import "CreateAccountSectionView.h"
#import "UIButton+Utilities.h"
#import "ProfileManager.h"
#import "ErrorHandler.h"
#import "LifecycleManager.h"
#import "LifecyclePhaseLogin.h"

static const CGFloat kTopOffset = 60.0;
static const CGFloat kVerticalOffset = 30.0;
static const CGFloat kFieldsOffset = 20.0;
static const CGFloat kHorizontalOffset = 40.0;
static const CGFloat kButtonHeight = 40.0;

@interface CreateAccountViewController () <CreateAccountSectionViewDelegate>

@property (strong, nonatomic) UIView *containerView;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) CreateAccountSectionView *usernameView;
@property (strong, nonatomic) CreateAccountSectionView *profileView;
@property (strong, nonatomic) UIButton *goButton;

@property (strong, nonatomic) MASConstraint *containerViewTopConstraint;

@property (strong, nonatomic) ProfileManager *profileManager;

@property (strong, nonatomic) CreateAccountSectionView *editingView;

@end

@implementation CreateAccountViewController

- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    _profileManager = [ProfileManager new];

    return self;
}

- (void)loadView
{
    [self loadViewWithBackgroundColor:[[AppContext sharedContext].appearance textMainColor]];

    [self createContainerView];
    [self createTitleLabel];
    [self createSectionViews];
    [self createGoButton];

    [self installConstraints];
}

#pragma mark -  Inherited

- (void)keyboardWillShowAnimated:(NSNotification *)keyboardNotification
{
    CGSize keyboardSize = [keyboardNotification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    CGFloat underButtonHeight = self.containerView.frame.size.height - CGRectGetMaxY(self.profileView.frame);

    CGFloat offset = MIN(0.0, underButtonHeight - keyboardSize.height);

    self.containerViewTopConstraint.offset(offset);
    [self.view layoutIfNeeded];
    NSLog(@"key");
}

- (void)keyboardWillHideAnimated:(NSNotification *)keyboardNotification
{
    self.containerViewTopConstraint.offset(0.0);
    [self.view layoutIfNeeded];
}

#pragma mark -  Actions

- (void)tapOnContainerView
{
    [self.view endEditing:YES];
}

- (void)goButtonPressed
{
    NSString *name = self.usernameView.text;
    NSString *profile = self.profileView.text;

    if (! name.length || ! profile.length) {
        [self showErrorMessage:NSLocalizedString(@"Please enter both username and profile name.",
                                                 @"CreateAccountViewController)")];
        return;
    }

    if ([self.profileManager.allProfiles containsObject:profile]) {
        [self showErrorMessage:NSLocalizedString(@"Profile with given name already exists", @"CreateAccountViewController")];
        return;
    }

    NSError *error;
    if (! [self.profileManager createProfileWithName:profile error:&error]) {
        [self showErrorMessage:[error localizedDescription]];
        return;
    }

    OCTManagerConfiguration *configuration = [self.profileManager configurationForProfileWithName:profile];
    OCTManager *manager = [[OCTManager alloc] initWithConfiguration:configuration error:&error];

    if (! manager) {
        [[AppContext sharedContext].errorHandler handleError:error type:ErrorHandlerTypeCreateOCTManager];
        return;
    }

    [manager.user setUserName:name error:nil];

    LifecyclePhaseLogin *phase = (LifecyclePhaseLogin *) [[AppContext sharedContext].lifecycleManager currentPhase];

    NSAssert([phase isKindOfClass:[LifecyclePhaseLogin class]], @"We should be in login phase, something went terrible wrong!");
    [phase finishPhaseWithToxManager:manager profileName:profile];
}

#pragma mark -  CreateAccountSectionView

- (BOOL)createAccountSectionViewShouldReturn:(CreateAccountSectionView *)view
{
    if ([view isEqual:self.usernameView]) {
        [self.profileView becomeFirstResponder];
    }
    else if ([view isEqual:self.profileView]) {
        [self.profileView resignFirstResponder];
        [self goButtonPressed];
    }

    return NO;
}

#pragma mark -  Private

- (void)createContainerView
{
    self.containerView = [UIView new];
    self.containerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.containerView];

    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnContainerView)];
    [self.containerView addGestureRecognizer:tapGR];
}

- (void)createTitleLabel
{
    self.titleLabel = [UILabel new];
    self.titleLabel.text = NSLocalizedString(@"Create Profile", @"CreateAccountViewController");
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueBoldWithSize:26.0];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self.containerView addSubview:self.titleLabel];
}

- (void)createSectionViews
{
    self.usernameView = [CreateAccountSectionView new];
    self.usernameView.delegate = self;
    self.usernameView.title = NSLocalizedString(@"How friends will see you?", @"CreateAccountViewController");
    self.usernameView.placeholder = NSLocalizedString(@"Username", @"CreateAccountViewController");
    self.usernameView.returnKeyType = UIReturnKeyNext;
    self.usernameView.maxTextUTF8Length = kOCTToxMaxNameLength;
    [self.containerView addSubview:self.usernameView];

    self.profileView = [CreateAccountSectionView new];
    self.profileView.delegate = self;
    self.profileView.title = NSLocalizedString(@"Name of this profile", @"CreateAccountViewController");
    self.profileView.placeholder = NSLocalizedString(@"Profile name", @"CreateAccountViewController");
    self.profileView.hint = NSLocalizedString(@"e.g. Home, iPhone", @"CreateAccountViewController");
    self.profileView.returnKeyType = UIReturnKeyGo;
    [self.containerView addSubview:self.profileView];
}

- (void)createGoButton
{
    NSString *title = NSLocalizedString(@"Go", @"LoginViewController");

    self.goButton = [UIButton loginButton];
    [self.goButton setTitle:title forState:UIControlStateNormal];
    [self.goButton addTarget:self action:@selector(goButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.goButton];
}

- (void)installConstraints
{
    [self.containerView makeConstraints:^(MASConstraintMaker *make) {
        self.containerViewTopConstraint = make.top.equalTo(self.view);
        make.left.right.bottom.equalTo(self.view);
    }];

    [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(kTopOffset);
        make.centerX.equalTo(self.containerView);
    }];

    [self.usernameView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.bottom).offset(kVerticalOffset);
        make.left.equalTo(self.containerView).offset(kHorizontalOffset);
        make.right.equalTo(self.containerView).offset(-kHorizontalOffset);
    }];

    [self.profileView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.usernameView.bottom).offset(kFieldsOffset);
        make.left.right.equalTo(self.usernameView);
    }];

    [self.goButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.profileView.bottom).offset(kVerticalOffset);
        make.left.right.equalTo(self.usernameView);
        make.height.equalTo(kButtonHeight);
    }];
}

- (void)showErrorMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:nil
                                message:message
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"CreateAccountViewController")
                      otherButtonTitles:nil] show];
}

@end
