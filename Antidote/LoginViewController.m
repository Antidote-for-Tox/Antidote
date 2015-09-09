//
//  LoginViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <objcTox/OCTManagerConfiguration.h>
#import <objcTox/OCTManager.h>

#import "LoginViewController.h"
#import "LifecycleManager.h"
#import "LifecyclePhaseLogin.h"
#import "ProfileManager.h"
#import "UserDefaultsManager.h"
#import "UIViewController+Utilities.h"
#import "AppearanceManager.h"
#import "UIImage+Utilities.h"
#import "UIColor+Utilities.h"
#import "CreateAccountViewController.h"
#import "ImportProfileViewController.h"
#import "FullscreenPicker.h"
#import "ErrorHandler.h"

static const CGFloat kLogoTopOffset = 40.0;
static const CGFloat kLogoBottomOffset = 20.0;

static const CGFloat kFormViewInsideOffset = 20.0;
static const CGFloat kFieldHeight = 40.0;
static const CGFloat kProfileToButtonOffset = 10.0;

static const CGFloat kFormToButtonOffset = 10.0;

static const CGFloat kBottomButtonsBottomOffset = -20.0;

static const NSTimeInterval kAnimationDuration = 0.3;

@interface LoginViewController () <UITextFieldDelegate, FullscreenPickerDelegate>

@property (strong, nonatomic) UIImageView *logoImageView;

@property (strong, nonatomic) UIView *formView;
@property (strong, nonatomic) UITextField *profileFakeTextField;
@property (strong, nonatomic) UIButton *profileButton;
@property (strong, nonatomic) UITextField *passwordField;
@property (strong, nonatomic) UIButton *hidePasswordFieldButton;

@property (strong, nonatomic) UIButton *loginButton;

@property (strong, nonatomic) UIButton *createAccountButton;
@property (strong, nonatomic) UIButton *importProfileButton;

@property (strong, nonatomic) MASConstraint *profileButtonBottomToFormConstraint;
@property (strong, nonatomic) MASConstraint *passwordFieldBottomToFormConstraint;

@property (strong, nonatomic) ProfileManager *profileManager;
@property (strong, nonatomic) NSString *activeProfile;

@end

@implementation LoginViewController

#pragma mark -  Lifecycle

- (instancetype)initWithActiveProfile:(NSString *)activeProfile
{
    self = [super init];

    if (! self) {
        return nil;
    }

    _profileManager = [ProfileManager new];

    _activeProfile = activeProfile ?: [_profileManager.allProfiles firstObject];

    return self;
}

- (void)loadView
{
    [self loadViewWithBackgroundColor:[[AppContext sharedContext].appearance textMainColor]];

    [self createLogoImageView];
    [self createFormViews];
    [self createLoginButton];
    [self createBottomButtons];

    [self installConstraints];

    [self updateFormAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -  Actions

- (void)createAccountButtonPressed
{
    [self.navigationController pushViewController:[CreateAccountViewController new] animated:YES];
}

- (void)importProfileButtonPressed
{
    [self.navigationController pushViewController:[ImportProfileViewController new] animated:YES];
}

- (void)loginButtonPressed
{
    OCTManagerConfiguration *configuration = [self.profileManager configurationForProfileWithName:self.activeProfile];

    if (self.passwordField.text.length) {
        configuration.passphrase = self.passwordField.text;
    }

    NSError *error;
    OCTManager *manager = [[OCTManager alloc] initWithConfiguration:configuration error:&error];

    if (! manager) {
        [[AppContext sharedContext].errorHandler handleError:error type:ErrorHandlerTypeCreateOCTManager];
        return;
    }

    LifecyclePhaseLogin *phase = (LifecyclePhaseLogin *) [[AppContext sharedContext].lifecycleManager currentPhase];

    NSAssert([phase isKindOfClass:[LifecyclePhaseLogin class]], @"We should be in login phase, something went terrible wrong!");
    [phase finishPhaseWithToxManager:manager profileName:self.activeProfile];
}

- (void)profileButtonPressed
{
    [self.view endEditing:YES];
    NSUInteger index = [self.profileManager.allProfiles indexOfObject:self.activeProfile];

    FullscreenPicker *picker = [[FullscreenPicker alloc] initWithStrings:self.profileManager.allProfiles selectedIndex:index];
    picker.delegate = self;

    [picker showAnimatedInView:self.view];
}

- (void)hidePasswordFieldButtonPressed
{
    [self.view endEditing:YES];
}

#pragma mark -  UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self loginButtonPressed];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.hidePasswordFieldButton.userInteractionEnabled = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.hidePasswordFieldButton.userInteractionEnabled = NO;
}

#pragma mark -  FullscreenPickerDelegate

- (void)fullscreenPicker:(FullscreenPicker *)picker willDismissWithSelectedIndex:(NSUInteger)index
{
    self.activeProfile = self.profileManager.allProfiles[index];
    [self updateFormAnimated:YES];
}

#pragma mark -  Private

- (void)createLogoImageView
{
    self.logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-logo"]];
    [self.view addSubview:self.logoImageView];
}

- (void)createFormViews
{
    self.formView = [UIView new];
    self.formView.backgroundColor = [UIColor whiteColor];
    self.formView.layer.cornerRadius = 5.0;
    self.formView.layer.masksToBounds = YES;
    [self.view addSubview:self.formView];

    self.profileFakeTextField = [UITextField new];
    self.profileFakeTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.profileFakeTextField.leftViewMode = UITextFieldViewModeAlways;
    self.profileFakeTextField.leftView = [self iconContainerWithImage:@"login-profile-icon"];
    [self.formView addSubview:self.profileFakeTextField];

    self.profileButton = [UIButton new];
    [self.profileButton addTarget:self action:@selector(profileButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.formView addSubview:self.profileButton];

    self.passwordField = [UITextField new];
    self.passwordField.delegate = self;
    self.passwordField.placeholder = NSLocalizedString(@"Password", @"LoginViewController");
    self.passwordField.secureTextEntry = YES;
    self.passwordField.returnKeyType = UIReturnKeyGo;
    self.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordField.leftView = [self iconContainerWithImage:@"login-password-icon"];
    [self.formView addSubview:self.passwordField];

    self.hidePasswordFieldButton = [UIButton new];
    self.hidePasswordFieldButton.userInteractionEnabled = NO;
    [self.hidePasswordFieldButton addTarget:self
                                     action:@selector(hidePasswordFieldButtonPressed)
                           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.hidePasswordFieldButton];
    [self.view sendSubviewToBack:self.hidePasswordFieldButton];
}

- (void)createLoginButton
{
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setTitle:NSLocalizedString(@"Log In", @"LoginViewController") forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueBoldWithSize:18.0];
    self.loginButton.layer.cornerRadius = 5.0;
    self.loginButton.layer.masksToBounds = YES;
    [self.loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    UIColor *bgColor = [[AppContext sharedContext].appearance loginButtonColor];
    UIImage *bgImage = [UIImage imageWithColor:bgColor size:CGSizeMake(1.0, 1.0)];
    [self.loginButton setBackgroundImage:bgImage forState:UIControlStateNormal];

    [self.view addSubview:self.loginButton];
}

- (void)createBottomButtons
{
    self.createAccountButton = [UIButton new];
    [self.createAccountButton setTitle:NSLocalizedString(@"Create account", @"LoginViewController")
                              forState:UIControlStateNormal];
    [self.createAccountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.createAccountButton addTarget:self
                                 action:@selector(createAccountButtonPressed)
                       forControlEvents:UIControlEventTouchUpInside];
    self.createAccountButton.titleLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:16.0];
    [self.view addSubview:self.createAccountButton];

    self.importProfileButton = [UIButton new];
    [self.importProfileButton setTitle:NSLocalizedString(@"Import profile", @"LoginViewController")
                              forState:UIControlStateNormal];
    [self.importProfileButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.importProfileButton addTarget:self
                                 action:@selector(importProfileButtonPressed)
                       forControlEvents:UIControlEventTouchUpInside];
    self.importProfileButton.titleLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:16.0];
    [self.view addSubview:self.importProfileButton];
}

- (void)installConstraints
{
    self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.logoImageView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(kLogoTopOffset);
    }];

    [self.formView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoImageView.bottom).offset(kLogoBottomOffset);
        make.centerX.equalTo(self.view);
        make.left.equalTo(self.view).offset(40.0);
        make.right.equalTo(self.view).offset(-40.0);
    }];

    [self.profileFakeTextField makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.profileButton);
    }];

    [self.profileButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.formView).offset(kFormViewInsideOffset);
        make.left.equalTo(self.formView).offset(kFormViewInsideOffset);
        make.right.equalTo(self.formView).offset(-kFormViewInsideOffset);
        make.height.equalTo(kFieldHeight);
        self.profileButtonBottomToFormConstraint = make.bottom.equalTo(self.formView).offset(-kFormViewInsideOffset);
    }];

    [self.passwordField makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.profileButton.bottom).offset(kProfileToButtonOffset);
        make.left.equalTo(self.formView).offset(kFormViewInsideOffset);
        make.right.equalTo(self.formView).offset(-kFormViewInsideOffset);
        make.height.equalTo(kFieldHeight);
        self.passwordFieldBottomToFormConstraint = make.bottom.equalTo(self.formView).offset(-kFormViewInsideOffset);
    }];

    [self.hidePasswordFieldButton makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.loginButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.formView.bottom).offset(kFormToButtonOffset);
        make.height.equalTo(kFieldHeight);
        make.width.equalTo(self.formView);
    }];

    [self.createAccountButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(self.loginButton.bottom).offset(30.0);
        make.left.equalTo(self.formView);
        make.bottom.equalTo(self.view).offset(kBottomButtonsBottomOffset);
    }];

    [self.importProfileButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(self.loginButton.bottom).offset(30.0);
        make.right.equalTo(self.formView);
        make.bottom.equalTo(self.view).offset(kBottomButtonsBottomOffset);
    }];
}

- (UIView *)iconContainerWithImage:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tintColor = [UIColor uColorWithWhite:200 alpha:1];

    UIView *container = [UIView new];
    container.backgroundColor = [UIColor clearColor];
    [container addSubview:imageView];

    CGRect frame = container.frame;
    frame.size.width = kFieldHeight - 15.0;
    frame.size.height = kFieldHeight;
    container.frame = frame;

    frame = imageView.frame;
    frame.origin.x = container.frame.size.width - frame.size.width;
    frame.origin.y = (kFieldHeight - frame.size.width) / 2 - 1.0;
    imageView.frame = frame;

    return container;
}

- (void)updateFormAnimated:(BOOL)animated
{
    if (self.profileFakeTextField.text == self.activeProfile) {
        return;
    }

    self.profileFakeTextField.text = self.activeProfile;
    self.passwordField.text = nil;

    if (! self.activeProfile) {
        return;
    }

    OCTManagerConfiguration *configuration = [self.profileManager configurationForProfileWithName:self.activeProfile];
    BOOL isEncrypted = [OCTManager isToxSaveEncryptedAtPath:configuration.fileStorage.pathForToxSaveFile];

    void (^updateForm)() = ^() {
        if (isEncrypted) {
            [self.profileButtonBottomToFormConstraint deactivate];
            [self.passwordFieldBottomToFormConstraint activate];
            self.passwordField.alpha = 1.0;
        }
        else {
            [self.profileButtonBottomToFormConstraint activate];
            [self.passwordFieldBottomToFormConstraint deactivate];
            self.passwordField.alpha = 0.0;
        }

        [self.view layoutIfNeeded];
    };

    if (animated) {
        [UIView animateWithDuration:kAnimationDuration animations:updateForm];
    }
    else {
        updateForm();
    }
}

@end
