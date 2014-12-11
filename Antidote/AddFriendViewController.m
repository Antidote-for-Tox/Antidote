//
//  AddFriendViewController.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 01.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "AddFriendViewController.h"
#import "UIViewController+Utilities.h"
#import "UIView+Utilities.h"
#import "ToxManager.h"
#import "ToxFunctions.h"
#import "QRScannerController.h"
#import "UIAlertView+BlocksKit.h"

@interface AddFriendViewController () <UITextViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UILabel *toxIdTitleLabel;
@property (strong, nonatomic) UIButton *toxIdQRButton;
@property (strong, nonatomic) UITextView *toxIdTextView;

@property (strong, nonatomic) UILabel *messageTitleLabel;
@property (strong, nonatomic) UITextView *messageTextView;

@property (strong, nonatomic) UIButton *sendRequestButton;

@end

@implementation AddFriendViewController

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.title = NSLocalizedString(@"Add", @"Add friend");
    }

    return self;
}

- (void)loadView
{
    [self loadWhiteView];

    [self createScrollView];
    [self createToxIdViews];
    [self createMessageViews];
    [self createSendRequestButton];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self adjustSubviews];
}

#pragma mark -  Actions

- (void)toxIdQRButtonPressed
{
    UINavigationController *navCon = [QRScannerController navigationWithScannerControllerWithSuccess:
        ^(QRScannerController *controller, NSArray *stringValues)
    {
        [self processQRStringValues:stringValues fromController:controller];

    } cancelBlock:^(QRScannerController *controller) {

        [self dismissViewControllerAnimated:YES completion:nil];
    }];

    [self presentViewController:navCon animated:YES completion:nil];
}

- (void)sendRequestButtonPressed
{
    [[ToxManager sharedInstance] sendFriendRequestWithAddress:self.toxIdTextView.text
                                                      message:self.messageTextView.text];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)finishEditingButtonPressed
{
    if (self.toxIdTextView.isFirstResponder) {
        [self.toxIdTextView resignFirstResponder];
    }

    if (self.messageTextView.isFirstResponder) {
        [self.messageTextView resignFirstResponder];
    }
}

#pragma mark -  UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView isEqual:self.messageTextView]) {
        CGPoint offset = CGPointZero;
        offset.y = 60.0;
        [self.scrollView setContentOffset:offset animated:YES];

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                 target:self
                                 action:@selector(finishEditingButtonPressed)];
    }

    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView isEqual:self.messageTextView]) {
        CGPoint offset = CGPointZero;
        offset.y = - self.scrollView.contentInset.top;
        [self.scrollView setContentOffset:offset animated:YES];

        self.navigationItem.rightBarButtonItem = nil;
    }

    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView isEqual:self.toxIdTextView]) {
        if ([text isEqual:@"\n"]) {
            [textView resignFirstResponder];
            return NO;
        }

        NSString *result = [textView.text stringByReplacingCharactersInRange:range withString:text];
        result = [result uppercaseString];

        NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefABCDEF"];
        NSArray *components = [result componentsSeparatedByCharactersInSet:[validChars invertedSet]];

        textView.text = [components componentsJoinedByString:@""];

        return NO;
    }

    return YES;
}

#pragma mark -  Private

- (void)createScrollView
{
    self.scrollView = [UIScrollView new];
    [self.view addSubview:self.scrollView];
}

- (void)createToxIdViews
{
    self.toxIdTitleLabel = [self.scrollView addLabelWithTextColor:[UIColor blackColor]
                                                          bgColor:[UIColor clearColor]];
    self.toxIdTitleLabel.text = NSLocalizedString(@"Tox ID", @"Add friend");

    self.toxIdQRButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.toxIdQRButton setTitle:NSLocalizedString(@"QR", @"Add friend") forState:UIControlStateNormal];
    [self.toxIdQRButton addTarget:self
                           action:@selector(toxIdQRButtonPressed)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.toxIdQRButton];

    self.toxIdTextView = [UITextView new];
    self.toxIdTextView.delegate = self;
    self.toxIdTextView.backgroundColor = [UIColor lightGrayColor];
    self.toxIdTextView.returnKeyType = UIReturnKeyDone;
    self.toxIdTextView.keyboardType = UIKeyboardTypeNamePhonePad;
    [self.scrollView addSubview:self.toxIdTextView];
}

- (void)createMessageViews
{
    self.messageTitleLabel = [self.scrollView addLabelWithTextColor:[UIColor blackColor]
                                                          bgColor:[UIColor clearColor]];
    self.messageTitleLabel.text = NSLocalizedString(@"Message", @"Add friend");

    self.messageTextView = [UITextView new];
    self.messageTextView.delegate = self;
    self.messageTextView.backgroundColor = [UIColor lightGrayColor];
    self.messageTextView.returnKeyType = UIReturnKeyDefault;
    [self.scrollView addSubview:self.messageTextView];
}

- (void)createSendRequestButton
{
    self.sendRequestButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendRequestButton setTitle:NSLocalizedString(@"Send request", @"Add friend") forState:UIControlStateNormal];
    [self.sendRequestButton addTarget:self
                           action:@selector(sendRequestButtonPressed)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.sendRequestButton];
}

- (void)adjustSubviews
{
    self.scrollView.frame = self.view.bounds;

    CGFloat currentOriginY = 0.0;
    const CGFloat yIndentation = 10.0;

    CGRect frame = CGRectZero;

    {
        [self.toxIdTitleLabel sizeToFit];
        frame = self.toxIdTitleLabel.frame;
        frame.origin.x = 10.0;
        frame.origin.y = currentOriginY + yIndentation;
        self.toxIdTitleLabel.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    {
        [self.toxIdQRButton sizeToFit];
        frame = self.toxIdQRButton.frame;
        frame.origin.x = self.view.bounds.size.width - frame.size.width - 20.0;
        frame.origin.y = self.toxIdTitleLabel.frame.origin.y;
        self.toxIdQRButton.frame = frame;
    }

    {
        const CGFloat xIndentation = self.toxIdTitleLabel.frame.origin.x;

        frame = CGRectZero;
        frame.origin.x = xIndentation;
        frame.origin.y = currentOriginY + yIndentation;
        frame.size.width = self.view.bounds.size.width - 2 * xIndentation;
        frame.size.height = 80.0;
        self.toxIdTextView.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    {
        [self.messageTitleLabel sizeToFit];
        frame = self.messageTitleLabel.frame;
        frame.origin.x = self.toxIdTitleLabel.frame.origin.x;
        frame.origin.y = currentOriginY + yIndentation;
        self.messageTitleLabel.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    [self.sendRequestButton sizeToFit];
    const CGFloat sendRequestButtonHeight = self.sendRequestButton.frame.size.height;

    {
        const CGFloat xIndentation = self.toxIdTitleLabel.frame.origin.x;

        frame = CGRectZero;
        frame.origin.x = xIndentation;
        frame.origin.y = currentOriginY + yIndentation;
        frame.size.width = self.view.bounds.size.width - 2 * xIndentation;
        frame.size.height = self.scrollView.bounds.size.height - self.scrollView.contentInset.top -
            self.scrollView.contentInset.bottom - frame.origin.y - sendRequestButtonHeight - 2 * yIndentation;
        self.messageTextView.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    {
        frame = self.sendRequestButton.frame;
        frame.origin.x = (self.view.bounds.size.width - frame.size.width) / 2;
        frame.origin.y = currentOriginY + yIndentation;;
        self.sendRequestButton.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.origin.x, currentOriginY + yIndentation);
}

- (void)processQRStringValues:(NSArray *)stringValues fromController:(QRScannerController *)controller
{
    NSString *goodString = nil;

    for (NSString *originalString in stringValues) {
        NSString *string = [originalString uppercaseString];
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        NSString *toxPrefix = @"TOX:";

        if ([string hasPrefix:toxPrefix] && string.length > toxPrefix.length) {
            string = [string substringFromIndex:toxPrefix.length];
        }

        if ([ToxFunctions isAddressString:string]) {
            goodString = string;
            break;
        }
    }

    if (goodString) {
        self.toxIdTextView.text = goodString;

        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        NSString *message = [NSString stringWithFormat:
            NSLocalizedString(@"Wrong code. It should contain Tox ID, but contains %@", @"Error"),
            [stringValues firstObject]];

        controller.pauseScanning = YES;

        [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Oops", @"Error")
                                       message:message
                             cancelButtonTitle:NSLocalizedString(@"Ok", @"Error")
                             otherButtonTitles:nil
                                       handler:^(UIAlertView *_, NSInteger __) {
                                           controller.pauseScanning = NO;
                                       }];
    }
}

@end
