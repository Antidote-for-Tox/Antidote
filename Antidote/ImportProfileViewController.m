//
//  ImportProfileViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 09/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <objcTox/OCTManager.h>
#import <objcTox/OCTManagerConfiguration.h>

#import "ImportProfileViewController.h"
#import "UIViewController+Utilities.h"
#import "AppearanceManager.h"
#import "CreateAccountSectionView.h"
#import "UIButton+Utilities.h"
#import "ProfileManager.h"
#import "ErrorHandler.h"
#import "LifecycleManager.h"
#import "LifecyclePhaseLogin.h"

static const CGFloat kTopOffset = 60.0;
static const CGFloat kHorizontalOffset = 40.0;
static const CGFloat kVerticalOffset = 20.0;
static const CGFloat kButtonHeight = 40.0;

@interface ImportProfileViewController () <CreateAccountSectionViewDelegate>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) CreateAccountSectionView *profileView;
@property (strong, nonatomic) CreateAccountSectionView *passwordView;
@property (strong, nonatomic) UIButton *goButton;

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) ProfileManager *profileManager;
@property (assign, nonatomic) BOOL isEncrypted;

@end

@implementation ImportProfileViewController

#pragma mark -  Lifecycle

- (instancetype)initWithProfileURL:(NSURL *)url
{
    self = [super init];

    if (! self) {
        return nil;
    }

    self.title = NSLocalizedString(@"Import Profile", @"ImportProfileViewController");

    _url = url;
    _profileManager = [ProfileManager new];

    _isEncrypted = [OCTManager isToxSaveEncryptedAtPath:[url path]];

    return self;
}

- (void)loadView
{
    [self loadViewWithBackgroundColor:[[AppContext sharedContext].appearance textMainColor]];

    [self configureView];
    [self createSectionViews];
    [self createGoButton];

    [self installConstraints];
}

#pragma mark -  Actions

- (void)tapOnContainerView
{
    [self.view endEditing:YES];
}

- (void)goButtonPressed
{
    NSString *profile = self.profileView.text;
    NSString *passphrase = self.isEncrypted ? self.passwordView.text : nil;

    if (! profile.length) {
        [self showErrorMessage:NSLocalizedString(@"Please enter profile name.", @"ImportProfileViewController)")];
        return;
    }

    if ([self.profileManager.allProfiles containsObject:profile]) {
        [self showErrorMessage:NSLocalizedString(@"Profile with given name already exists", @"ImportProfileViewController")];
        return;
    }

    NSError *error;
    if (! [self.profileManager createProfileWithName:profile error:&error]) {
        [self showErrorMessage:[error localizedDescription]];
        return;
    }

    OCTManagerConfiguration *configuration = [self.profileManager configurationForProfileWithName:profile
                                                                                       passphrase:passphrase];
    configuration.importToxSaveFromPath = [self.url path];

    OCTManager *manager = [[OCTManager alloc] initWithConfiguration:configuration error:&error];

    if (! manager) {
        [self.profileManager deleteProfileWithName:profile error:nil];
        [[AppContext sharedContext].errorHandler handleError:error type:ErrorHandlerTypeCreateOCTManager];
        return;
    }

    LifecyclePhaseLogin *phase = (LifecyclePhaseLogin *) [[AppContext sharedContext].lifecycleManager currentPhase];

    NSAssert([phase isKindOfClass:[LifecyclePhaseLogin class]], @"We should be in login phase, something went terrible wrong!");
    [phase finishPhaseWithToxManager:manager profileName:profile];
}

#pragma mark -  CreateAccountSectionView

- (BOOL)createAccountSectionViewShouldReturn:(CreateAccountSectionView *)view
{
    if (self.isEncrypted) {
        if ([view isEqual:self.profileView]) {
            [self.passwordView becomeFirstResponder];
        }
        else if ([view isEqual:self.passwordView]) {
            [self.passwordView resignFirstResponder];
            [self goButtonPressed];
        }
    }
    else {
        if ([view isEqual:self.profileView]) {
            [self.profileView resignFirstResponder];
            [self goButtonPressed];
        }
    }

    return NO;
}

#pragma mark -  Private

- (void)configureView
{
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnContainerView)];
    [self.view addGestureRecognizer:tapGR];
}

- (void)createSectionViews
{
    self.profileView = [CreateAccountSectionView new];
    self.profileView.delegate = self;
    self.profileView.text = [[self.url lastPathComponent] stringByDeletingPathExtension];
    self.profileView.title = NSLocalizedString(@"How to call this profile?", @"ImportProfileViewController");
    self.profileView.placeholder = NSLocalizedString(@"Profile name", @"ImportProfileViewController");
    self.profileView.hint = NSLocalizedString(@"e.g. Home, iPhone", @"ImportProfileViewController");
    self.profileView.returnKeyType = UIReturnKeyGo;
    [self.view addSubview:self.profileView];

    if (self.isEncrypted) {
        self.profileView.returnKeyType = UIReturnKeyNext;

        self.passwordView = [CreateAccountSectionView new];
        self.passwordView.delegate = self;
        self.passwordView.title = NSLocalizedString(@"Password", @"ImportProfileViewController");
        self.passwordView.placeholder = NSLocalizedString(@"Password", @"ImportProfileViewController");
        self.passwordView.returnKeyType = UIReturnKeyGo;
        self.passwordView.secureTextEntry = YES;
        [self.view addSubview:self.passwordView];
    }
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
    [self.profileView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kTopOffset);
        make.left.equalTo(self.view).offset(kHorizontalOffset);
        make.right.equalTo(self.view).offset(-kHorizontalOffset);
    }];

    UIView *bottomView = self.profileView;

    if (self.isEncrypted) {
        [self.passwordView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bottomView.bottom).offset(kVerticalOffset);
            make.left.right.equalTo(bottomView);
        }];

        bottomView = self.passwordView;
    }

    [self.goButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomView.bottom).offset(kVerticalOffset);
        make.left.right.equalTo(bottomView);
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
