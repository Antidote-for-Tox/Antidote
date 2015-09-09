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
#import "ImportProfileViewController.h"
#import "FullscreenPicker.h"
#import "ErrorHandler.h"
#import "LoginProfileFormView.h"

static const CGFloat kLogoTopOffset = 40.0;
static const CGFloat kLogoBottomOffset = 20.0;

@interface LoginViewController () <FullscreenPickerDelegate, LoginProfileFormViewDelegate>

@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) LoginProfileFormView *profileFormView;

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
    [self createProfileFormView];

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
    [self.navigationController pushViewController:[ImportProfileViewController new] animated:YES];
}

#pragma mark -  Private

- (void)createLogoImageView
{
    self.logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login-logo"]];
    self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.logoImageView];
}

- (void)createProfileFormView
{
    self.profileFormView = [LoginProfileFormView new];
    self.profileFormView.delegate = self;
    [self.view addSubview:self.profileFormView];
}

- (void)installConstraints
{
    [self.logoImageView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(kLogoTopOffset);
    }];

    [self.profileFormView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoImageView.bottom).offset(kLogoBottomOffset);
        make.left.right.bottom.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
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

@end
