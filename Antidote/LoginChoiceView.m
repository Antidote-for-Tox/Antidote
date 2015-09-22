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
#import "AppearanceManager.h"

static const CGFloat kHorizontalOffset = 40.0;
static const CGFloat kVerticalOffset = 20.0;
static const CGFloat kOrVerticalOffset = 8.0;
static const CGFloat kButtonHeight = 40.0;

@interface LoginChoiceView ()

@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UIButton *createAccountButton;
@property (strong, nonatomic) UILabel *orLabel;
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

    [self createLabels];
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

- (void)createLabels
{
    self.descriptionLabel = [UILabel new];
    self.descriptionLabel.text = NSLocalizedString(@"Welcome to Antidote!", @"LoginViewController");
    self.descriptionLabel.textColor = [[AppContext sharedContext].appearance loginDescriptionTextColor];
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.descriptionLabel];

    self.orLabel = [UILabel new];
    self.orLabel.text = NSLocalizedString(@"or", @"LoginViewController");
    self.orLabel.textColor = [[AppContext sharedContext].appearance loginDescriptionTextColor];
    self.orLabel.textAlignment = NSTextAlignmentCenter;
    self.orLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.orLabel];
}

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
    [self.descriptionLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self).offset(kHorizontalOffset);
        make.right.equalTo(self).offset(-kHorizontalOffset);
    }];

    [self.createAccountButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descriptionLabel.bottom).offset(kVerticalOffset);
        make.left.equalTo(self).offset(kHorizontalOffset);
        make.right.equalTo(self).offset(-kHorizontalOffset);
        make.height.equalTo(kButtonHeight);
    }];

    [self.orLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.createAccountButton.bottom).offset(kOrVerticalOffset);
        make.left.equalTo(self).offset(kHorizontalOffset);
        make.right.equalTo(self).offset(-kHorizontalOffset);
    }];

    [self.importProfileButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.orLabel.bottom).offset(kOrVerticalOffset);
        make.left.equalTo(self).offset(kHorizontalOffset);
        make.right.equalTo(self).offset(-kHorizontalOffset);
        make.height.equalTo(kButtonHeight);
        make.bottom.equalTo(self);
    }];
}

@end
