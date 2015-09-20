//
//  LoginChoiceView.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 20/09/15.
//  Copyright © 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "LoginChoiceView.h"
#import "UIButton+Utilities.h"

static const CGFloat kHorizontalOffset = 40.0;
static const CGFloat kVerticalOffset = 20.0;
static const CGFloat kButtonHeight = 40.0;

@interface LoginChoiceView ()

@property (strong, nonatomic) UIButton *createAccountButton;
@property (strong, nonatomic) UIButton *importProfileButton;

@end

@implementation LoginChoiceView

#pragma mark -  Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (! self) {
        return nil;
    }

    [self createButtons];

    [self installConstraints];

    return self;
}

#pragma mark -  Actions

- (void)createAccountButtonPressed
{
    [self.delegate loginChoiceViewCreateAccountButtonPressed:self];
}

- (void)importProfileButtonPressed
{
    [self.delegate loginChoiceViewImportProfileButtonPressed:self];
}

#pragma mark -  Private

- (void)createButtons
{
    self.createAccountButton = [UIButton loginButton];
    [self.createAccountButton setTitle:NSLocalizedString(@"Create Account", @"LoginViewController") forState:UIControlStateNormal];
    [self.createAccountButton addTarget:self
                                 action:@selector(createAccountButtonPressed)
                       forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.createAccountButton];

    self.importProfileButton = [UIButton loginButton];
    [self.importProfileButton setTitle:NSLocalizedString(@"Import Profile", @"LoginViewController") forState:UIControlStateNormal];
    [self.importProfileButton addTarget:self
                                 action:@selector(importProfileButtonPressed)
                       forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.importProfileButton];
}

- (void)installConstraints
{
    [self.createAccountButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self);
        make.left.equalTo(self).offset(kHorizontalOffset);
        make.right.equalTo(self).offset(-kHorizontalOffset);
        make.height.equalTo(kButtonHeight);
    }];

    [self.importProfileButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.createAccountButton.bottom).offset(kVerticalOffset);
        make.centerX.equalTo(self);
        make.left.equalTo(self).offset(kHorizontalOffset);
        make.right.equalTo(self).offset(-kHorizontalOffset);
        make.height.equalTo(kButtonHeight);
        make.bottom.equalTo(self);
    }];
}

@end
