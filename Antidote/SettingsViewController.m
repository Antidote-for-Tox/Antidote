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
#import "MFMailComposeViewController+BlocksKit.h"
#import "UIAlertView+BlocksKit.h"
#import "DDFileLogger.h"

@interface SettingsViewController () <UITextFieldDelegate, ToxIdViewDelegate, SettingsColorViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UITextField *statusMessageField;

@property (strong, nonatomic) ToxIdView *toxIdView;

@property (strong, nonatomic) SettingsColorView *colorView;

@property (strong, nonatomic) UIButton *feedbackButton;

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
    [self createFeedbackButton];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self adjustSubviews];
}

#pragma mark -  Actions

- (void)feedbackButtonPressed
{
    if (! [MFMailComposeViewController canSendMail]) {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:NSLocalizedString(@"Please configure your mail settings", @"Settings")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"OK", @"Settings")
                          otherButtonTitles:nil] show];

        return;
    }

    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:NSLocalizedString(@"Add log files?", @"Settings")];

    __weak SettingsViewController *weakSelf = self;

    [alertView bk_setCancelButtonWithTitle:NSLocalizedString(@"No", @"Settings") handler:^{
        [weakSelf showMailControllerWithLogs:NO];
    }];

    [alertView bk_addButtonWithTitle:NSLocalizedString(@"Yes", @"Settings") handler:^{
        [weakSelf showMailControllerWithLogs:YES];
    }];

    [alertView show];
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

- (void)toxIdView:(ToxIdView *)view wantsToShowQRWithToxId:(NSString *)toxId
{
    QRViewerController *qrVC = [[QRViewerController alloc] initWithToxId:toxId];

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

- (void)createFeedbackButton
{
    self.feedbackButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.feedbackButton setTitle:NSLocalizedString(@"Feedback", @"Settings") forState:UIControlStateNormal];
    [self.feedbackButton addTarget:self
                            action:@selector(feedbackButtonPressed)
                  forControlEvents:UIControlEventTouchUpInside];

    [self.scrollView addSubview:self.feedbackButton];
}

- (void)adjustSubviews
{
    self.scrollView.frame = self.view.bounds;

    __unused CGFloat currentOriginY = 0.0;
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

    {
        [self.feedbackButton sizeToFit];
        frame = self.feedbackButton.frame;
        frame.origin.x = (self.view.frame.size.width - frame.size.width) / 2;
        frame.origin.y = self.scrollView.frame.size.height - frame.size.height - yIndentation -
            self.scrollView.contentInset.top - self.scrollView.contentInset.bottom;
        self.feedbackButton.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.origin.x, currentOriginY + yIndentation);
}

- (void)showMailControllerWithLogs:(BOOL)withLogs
{
    MFMailComposeViewController *vc = [MFMailComposeViewController new];
    vc.navigationBar.tintColor = [AppearanceManager textMainColor];
    [vc setSubject:@"Feedback"];
    [vc setToRecipients:@[@"antidote@dvor.me"]];

    if (withLogs) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

        for (NSString *path in [delegate getLogFilesPaths]) {
            NSData *data = [NSData dataWithContentsOfFile:path];

            if (data) {
                [vc addAttachmentData:data mimeType:@"text/plain" fileName:[path lastPathComponent]];
            }
        }
    }

    vc.bk_completionBlock = ^(MFMailComposeViewController *vc, MFMailComposeResult result, NSError *error) {
        [self dismissViewControllerAnimated:YES completion:nil];
    };

    [self presentViewController:vc animated:YES completion:nil];
}

@end
