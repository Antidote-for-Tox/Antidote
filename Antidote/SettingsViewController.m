//
//  SettingsViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "SettingsViewController.h"
#import "ToxManager.h"
#import "QRViewerController.h"
#import "UIViewController+Utilities.h"
#import "UIView+Utilities.h"
#import "ToxIdView.h"
#import "SettingsColorView.h"
#import "AppDelegate.h"
#import "NSString+Utilities.h"

@interface SettingsViewController () <UITextFieldDelegate, ToxIdViewDelegate, SettingsColorViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UITextField *statusMessageField;

@property (strong, nonatomic) ToxIdView *toxIdView;

@property (strong, nonatomic) SettingsColorView *colorView;

@end

@implementation SettingsViewController

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.title = NSLocalizedString(@"Settings", @"Settings");
    }

    return self;
}

- (void)loadView
{
    [self loadWhiteView];

    [self createScrollView];
    [self createNameField];
    [self createStatusMessageField];
    [self createToxIdView];
    [self createColorView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self adjustSubviews];
}

#pragma mark -  UITextFieldDelegate

- (BOOL)             textField:(UITextField *)textField
 shouldChangeCharactersInRange:(NSRange)range
             replacementString:(NSString *)string
{
    NSString *resultText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSUInteger maxLength = NSUIntegerMax;

    if ([textField isEqual:self.nameField]) {
        maxLength = TOX_MAX_NAME_LENGTH;
    }
    else if ([textField isEqual:self.statusMessageField]) {
        maxLength = TOX_MAX_STATUSMESSAGE_LENGTH;
    }

    if ([resultText lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > maxLength) {
        textField.text = [resultText substringToByteLength:maxLength usingEncoding:NSUTF8StringEncoding];

        return NO;
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.nameField]) {
        [textField resignFirstResponder];
    }
    else if ([textField isEqual:self.statusMessageField]) {
        [textField resignFirstResponder];
    }

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.nameField]) {
        [ToxManager sharedInstance].userName = textField.text;
    }
    else if ([textField isEqual:self.statusMessageField]) {
        [ToxManager sharedInstance].userStatusMessage = textField.text;
    }
}

#pragma mark -  ToxIdViewDelegate

- (void)toxIdView:(ToxIdView *)view wantsToShowQRWithText:(NSString *)text
{
    QRViewerController *qrVC = [[QRViewerController alloc] initWithText:text];

    [self presentViewController:qrVC animated:YES completion:nil];
}

#pragma mark -  SettingsColorViewDelegate

- (void)settingsColorView:(SettingsColorView *)view didSelectScheme:(AppearanceManagerColorscheme)scheme
{
    [AppearanceManager changeColorschemeTo:scheme];

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    [delegate recreateControllersAndShow:AppDelegateTabIndexSettings];
}

#pragma mark -  Private

- (void)createScrollView
{
    self.scrollView = [UIScrollView new];
    [self.view addSubview:self.scrollView];
}

- (void)createNameField
{
    self.nameField = [UITextField new];
    self.nameField.delegate = self;
    self.nameField.placeholder = NSLocalizedString(@"Name", @"Settings");
    self.nameField.borderStyle = UITextBorderStyleRoundedRect;
    self.nameField.returnKeyType = UIReturnKeyDone;
    [self.scrollView addSubview:self.nameField];

    self.nameField.text = [ToxManager sharedInstance].userName;
}

- (void)createStatusMessageField
{
    self.statusMessageField = [UITextField new];
    self.statusMessageField.delegate = self;
    self.statusMessageField.placeholder = NSLocalizedString(@"Status", @"Settings");
    self.statusMessageField.borderStyle = UITextBorderStyleRoundedRect;
    self.statusMessageField.returnKeyType = UIReturnKeyDone;
    [self.scrollView addSubview:self.statusMessageField];

    self.statusMessageField.text = [ToxManager sharedInstance].userStatusMessage;
}

- (void)createToxIdView
{
    NSString *toxId = [ToxManager sharedInstance].toxId;

    self.toxIdView = [[ToxIdView alloc] initWithId:toxId];
    self.toxIdView.delegate = self;
    [self.scrollView addSubview:self.toxIdView];
}

- (void)createColorView
{
    self.colorView = [SettingsColorView new];
    self.colorView.delegate = self;
    [self.scrollView addSubview:self.colorView];
}

- (void)adjustSubviews
{
    self.scrollView.frame = self.view.bounds;

    CGFloat currentOriginY = 0.0;
    const CGFloat yIndentation = 10.0;

    CGRect frame = CGRectZero;

    {
        frame = self.nameField.frame;
        frame.size.width = 240.0;
        frame.size.height = 30.0;
        frame.origin.x = self.view.bounds.size.width - frame.size.width - 10.0;
        frame.origin.y = currentOriginY + yIndentation;

        self.nameField.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    {
        frame = self.statusMessageField.frame;
        frame.size.width = 240.0;
        frame.size.height = 30.0;
        frame.origin.x = self.view.bounds.size.width - frame.size.width - 10.0;
        frame.origin.y = currentOriginY + yIndentation;

        self.statusMessageField.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    {
        frame = self.toxIdView.frame;
        frame.origin.y = currentOriginY + yIndentation;
        self.toxIdView.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    {
        [self.colorView sizeToFit];
        frame = self.colorView.frame;
        frame.origin.x = (self.view.frame.size.width - frame.size.width) / 2;
        frame.origin.y = currentOriginY + yIndentation;
        self.colorView.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.origin.x, currentOriginY + yIndentation);
}

@end
