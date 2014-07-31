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
#import "NSString+Utilities.h"
#import "UIViewController+Utilities.h"
#import "UIView+Utilities.h"

@interface SettingsViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UITextField *nameField;

@property (strong, nonatomic) UILabel *toxIdTitleLabel;
@property (strong, nonatomic) UIButton *toxIdQRButton;
@property (strong, nonatomic) CopyLabel *toxIdValueLabel;

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
    [self createToxIdViews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self adjustSubviews];
}

#pragma mark -  Actions

- (void)toxIdQRButtonPressed
{
    QRViewerController *qrVC = [[QRViewerController alloc] initWithText:[ToxManager sharedInstance].toxId];

    [self presentViewController:qrVC animated:YES completion:nil];
}

#pragma mark -  UITextFieldDelegate

- (BOOL)             textField:(UITextField *)textField
 shouldChangeCharactersInRange:(NSRange)range
             replacementString:(NSString *)string
{
    NSString *resultText = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if ([textField isEqual:self.nameField]) {
        if (resultText.length > TOX_MAX_NAME_LENGTH) {
            textField.text = [resultText substringToIndex:TOX_MAX_NAME_LENGTH];

            return NO;
        }
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.nameField]) {
        [textField resignFirstResponder];

        [[ToxManager sharedInstance] setUserName:textField.text];
    }

    return YES;
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

    self.nameField.text = [[ToxManager sharedInstance] userName];
}

- (void)createToxIdViews
{
    self.toxIdTitleLabel = [self.scrollView addLabelWithTextColor:[UIColor blackColor]
                                                          bgColor:[UIColor clearColor]];
    self.toxIdTitleLabel.text = NSLocalizedString(@"My Tox ID", @"Settings");

    self.toxIdQRButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.toxIdQRButton setTitle:NSLocalizedString(@"QR", @"Settings") forState:UIControlStateNormal];
    [self.toxIdQRButton addTarget:self
                           action:@selector(toxIdQRButtonPressed)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.toxIdQRButton];

    self.toxIdValueLabel = [self.scrollView addCopyLabelWithTextColor:[UIColor grayColor]
                                                              bgColor:[UIColor clearColor]];
    self.toxIdValueLabel.numberOfLines = 0;
    self.toxIdValueLabel.text = [[ToxManager sharedInstance] toxId];
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
        frame.size = [self.toxIdTitleLabel.text stringSizeWithFont:self.toxIdTitleLabel.font];
        frame.origin.x = 10.0;
        frame.origin.y = currentOriginY + yIndentation;
        self.toxIdTitleLabel.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    {
        NSString *title = [self.toxIdQRButton titleForState:UIControlStateNormal];
        UIFont *font = self.toxIdQRButton.titleLabel.font;

        frame = CGRectZero;
        frame.size = [title stringSizeWithFont:font];
        frame.origin.x = self.view.bounds.size.width - frame.size.width - 20.0;
        frame.origin.y = self.toxIdTitleLabel.frame.origin.y;
        self.toxIdQRButton.frame = frame;
    }

    {
        const CGFloat xIndentation = self.toxIdTitleLabel.frame.origin.x;
        const CGFloat maxWidth = self.scrollView.bounds.size.width - 2 * xIndentation;

        frame = CGRectZero;
        frame.size = [self.toxIdValueLabel.text stringSizeWithFont:self.toxIdValueLabel.font
                                                 constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)];
        frame.origin.x = xIndentation;
        frame.origin.y = currentOriginY + yIndentation;
        self.toxIdValueLabel.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.origin.x, currentOriginY + yIndentation);
}

@end
