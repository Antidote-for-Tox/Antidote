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
#import "CreateAccountViewController.h"
#import "TextViewController.h"
#import "FullscreenPicker.h"
#import "ErrorHandler.h"
#import "LoginProfileFormView.h"

static const CGFloat kLogoTopOffset = -200.0;
static const CGFloat kLogoHeight = 100.0;
static const CGFloat kLogoBottomOffset = 40.0;

@interface LoginViewController () <FullscreenPickerDelegate, LoginProfileFormViewDelegate>

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) LoginProfileFormView *profileFormView;

@property (strong, nonatomic) MASConstraint *containerViewTopConstraint;

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

    [self createContainerView];
    [self createLogoImageView];
    [self createProfileFormView];

    [self installConstraints];

    [self updateFormAnimated:NO];
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

#pragma mark -  Inherited

- (void)keyboardWillShowAnimated:(NSNotification *)keyboardNotification
{
    CGSize keyboardSize = [keyboardNotification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    CGFloat underLoginHeight = self.containerView.frame.size.height -
                               CGRectGetMinY(self.profileFormView.frame) -
                               [self.profileFormView loginButtonBottomY];

    CGFloat offset = MIN(0.0, underLoginHeight - keyboardSize.height);

    self.containerViewTopConstraint.offset(offset);
    [self.view layoutIfNeeded];
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

#pragma mark -  FullscreenPickerDelegate

- (void)fullscreenPicker:(FullscreenPicker *)picker willDismissWithSelectedIndex:(NSUInteger)index
{
    NSString *profile = self.profileManager.allProfiles[index];

    if ([self.activeProfile isEqualToString:profile]) {
        return;
    }

    self.activeProfile = profile;
    [self updateFormAnimated:YES];
}

#pragma mark -  LoginProfileFormViewDelegate

- (void)loginProfileFormViewProfileButtonPressed:(LoginProfileFormView *)view
{
    NSUInteger index = [self.profileManager.allProfiles indexOfObject:self.activeProfile];

    FullscreenPicker *picker = [[FullscreenPicker alloc] initWithStrings:self.profileManager.allProfiles selectedIndex:index];
    picker.delegate = self;

    [picker showAnimatedInView:self.view];
}

- (void)loginProfileFormViewLoginButtonPressed:(LoginProfileFormView *)view
{
    OCTManagerConfiguration *configuration = [self.profileManager configurationForProfileWithName:self.activeProfile];

    if (self.profileFormView.passwordString.length) {
        configuration.passphrase = self.profileFormView.passwordString;
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

- (void)loginProfileFormViewCreateAccountButtonPressed:(LoginProfileFormView *)view
{
    [self.navigationController pushViewController:[CreateAccountViewController new] animated:YES];
}

- (void)loginProfileFormViewImportProfileButtonPressed:(LoginProfileFormView *)view
{
    TextViewController *textVC = [TextViewController new];
    textVC.backgroundColor = self.view.backgroundColor;

    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"import-profile" ofType:@"html"];

    textVC.html = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];

    [self.navigationController pushViewController:textVC animated:YES];
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

- (void)createLogoImageView
{
    UIImage *image = [UIImage imageNamed:@"login-logo"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    self.logoImageView = [[UIImageView alloc] initWithImage:image];
    self.logoImageView.tintColor = [[AppContext sharedContext].appearance bubbleOutgoingColor];
    self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.containerView addSubview:self.logoImageView];
}

- (void)createProfileFormView
{
    self.profileFormView = [LoginProfileFormView new];
    self.profileFormView.delegate = self;
    [self.containerView addSubview:self.profileFormView];
}

- (void)installConstraints
{
    [self.containerView makeConstraints:^(MASConstraintMaker *make) {
        self.containerViewTopConstraint = make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.equalTo(self.view);
    }];

    [self.logoImageView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView);
        make.top.equalTo(self.containerView.centerY).offset(kLogoTopOffset);
        make.height.equalTo(kLogoHeight);
    }];

    [self.profileFormView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoImageView.bottom).offset(kLogoBottomOffset);
        make.left.right.bottom.equalTo(self.containerView);
    }];
}

- (void)updateFormAnimated:(BOOL)animated
{
    self.profileFormView.profileString = self.activeProfile;
    self.profileFormView.passwordString = nil;

    if (! self.activeProfile) {
        return;
    }

    OCTManagerConfiguration *configuration = [self.profileManager configurationForProfileWithName:self.activeProfile];
    BOOL isEncrypted = [OCTManager isToxSaveEncryptedAtPath:configuration.fileStorage.pathForToxSaveFile];

    [self.profileFormView showPasswordField:isEncrypted animated:animated];
}

- (void)performAnimatedBlock:(void (^)())block withKeyboardNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];

    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];

    UIViewAnimationOptions options = 0;

    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            options |= UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            options |= UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options |= UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            options |= UIViewAnimationOptionCurveLinear;
            break;
    }

    [UIView animateWithDuration:duration delay:0.0 options:options animations:block completion:nil];
}

@end
