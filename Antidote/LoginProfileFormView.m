//
//  LoginProfileFormView.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 09/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "LoginProfileFormView.h"
#import "AppearanceManager.h"
#import "UIImage+Utilities.h"
#import "UIColor+Utilities.h"

static const CGFloat kFormHorizontalOffset = 40.0;
static const CGFloat kOffsetInForm = 20.0;
static const CGFloat kProfileToButtonOffset = 10.0;
static const CGFloat kFieldHeight = 40.0;
static const CGFloat kFormToButtonOffset = 10.0;
static const CGFloat kBottomButtonsBottomOffset = -20.0;

static const NSTimeInterval kAnimationDuration = 0.3;

@interface LoginProfileFormView () <UITextFieldDelegate>

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

@end

@implementation LoginProfileFormView

#pragma mark -  Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (! self) {
        return nil;
    }

    [self createFormViews];
    [self createLoginButton];
    [self createBottomButtons];

    [self installConstraints];

    return self;
}

#pragma mark -  Properties

- (void)setProfileString:(NSString *)text
{
    self.profileFakeTextField.text = text;
}

- (NSString *)profileString
{
    return self.profileFakeTextField.text;
}

- (void)setPasswordString:(NSString *)text
{
    self.passwordField.text = text;
}

- (NSString *)passwordString
{
    return self.passwordField.text;
}

#pragma mark -  Actions

- (void)profileButtonPressed
{
    [self endEditing:YES];
    [self.delegate loginProfileFormViewProfileButtonPressed:self];
}

- (void)hidePasswordFieldButtonPressed
{
    [self endEditing:YES];
}

- (void)loginButtonPressed
{
    [self.delegate loginProfileFormViewLoginButtonPressed:self];
}

- (void)createAccountButtonPressed
{
    [self.delegate loginProfileFormViewCreateAccountButtonPressed:self];
}

- (void)importProfileButtonPressed
{
    [self.delegate loginProfileFormViewImportProfileButtonPressed:self];
}

#pragma mark -  Public

- (void)showPasswordField:(BOOL)show animated:(BOOL)animated
{
    void (^updateForm)() = ^() {
        if (show) {
            [self.profileButtonBottomToFormConstraint deactivate];
            [self.passwordFieldBottomToFormConstraint activate];
            self.passwordField.alpha = 1.0;
        }
        else {
            [self.profileButtonBottomToFormConstraint activate];
            [self.passwordFieldBottomToFormConstraint deactivate];
            self.passwordField.alpha = 0.0;
        }

        [self layoutIfNeeded];
    };

    if (animated) {
        [UIView animateWithDuration:kAnimationDuration animations:updateForm];
    }
    else {
        updateForm();
    }
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

#pragma mark -  Private

- (void)createFormViews
{
    self.formView = [UIView new];
    self.formView.backgroundColor = [UIColor whiteColor];
    self.formView.layer.cornerRadius = 5.0;
    self.formView.layer.masksToBounds = YES;
    [self addSubview:self.formView];

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
    [self addSubview:self.hidePasswordFieldButton];
    [self sendSubviewToBack:self.hidePasswordFieldButton];
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

    [self addSubview:self.loginButton];
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
    [self addSubview:self.createAccountButton];

    self.importProfileButton = [UIButton new];
    [self.importProfileButton setTitle:NSLocalizedString(@"Import profile", @"LoginViewController")
                              forState:UIControlStateNormal];
    [self.importProfileButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.importProfileButton addTarget:self
                                 action:@selector(importProfileButtonPressed)
                       forControlEvents:UIControlEventTouchUpInside];
    self.importProfileButton.titleLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:16.0];
    [self addSubview:self.importProfileButton];
}

- (void)installConstraints
{
    [self.formView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self);
        make.left.equalTo(self).offset(kFormHorizontalOffset);
        make.right.equalTo(self).offset(-kFormHorizontalOffset);
    }];

    [self.profileFakeTextField makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.profileButton);
    }];

    [self.profileButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.formView).offset(kOffsetInForm);
        make.left.equalTo(self.formView).offset(kOffsetInForm);
        make.right.equalTo(self.formView).offset(-kOffsetInForm);
        make.height.equalTo(kFieldHeight);
        self.profileButtonBottomToFormConstraint = make.bottom.equalTo(self.formView).offset(-kOffsetInForm);
    }];

    [self.passwordField makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.profileButton.bottom).offset(kProfileToButtonOffset);
        make.left.equalTo(self.formView).offset(kOffsetInForm);
        make.right.equalTo(self.formView).offset(-kOffsetInForm);
        make.height.equalTo(kFieldHeight);
        self.passwordFieldBottomToFormConstraint = make.bottom.equalTo(self.formView).offset(-kOffsetInForm);
    }];

    [self.hidePasswordFieldButton makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [self.loginButton makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.formView.bottom).offset(kFormToButtonOffset);
        make.height.equalTo(kFieldHeight);
        make.width.equalTo(self.formView);
    }];

    [self.createAccountButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(self.loginButton.bottom).offset(30.0);
        make.left.equalTo(self.formView);
        make.bottom.equalTo(self).offset(kBottomButtonsBottomOffset);
    }];

    [self.importProfileButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(self.loginButton.bottom).offset(30.0);
        make.right.equalTo(self.formView);
        make.bottom.equalTo(self).offset(kBottomButtonsBottomOffset);
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

@end
