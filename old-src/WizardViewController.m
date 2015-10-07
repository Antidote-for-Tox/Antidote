//
//  WizardViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 22/09/15.
//  Copyright © 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "WizardViewController.h"
#import "UIViewController+Utilities.h"

static const CGFloat kTopOffset = 100.0;
static const CGFloat kHorizontalOffset = 40.0;
static const CGFloat kFieldHeight = 40.0;

@interface WizardViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *textField;

@end

@implementation WizardViewController

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    // load view
    [self view];

    return self;
}

- (void)loadView
{
    [self loadWhiteView];

    [self createTextField];
    [self installConstraints];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.textField becomeFirstResponder];
}

#pragma mark -  UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.returnKeyPressedBlock) {
        self.returnKeyPressedBlock(self);
    }

    return YES;
}

#pragma mark -  Private

- (void)createTextField
{
    self.textField = [UITextField new];
    self.textField.delegate = self;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.textField];
}

- (void)installConstraints
{
    [self.textField makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kTopOffset);
        make.left.equalTo(self.view).offset(kHorizontalOffset);
        make.right.equalTo(self.view).offset(-kHorizontalOffset);
        make.height.equalTo(kFieldHeight);
    }];
}

@end
