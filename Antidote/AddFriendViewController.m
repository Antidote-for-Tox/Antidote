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
#import "UIColor+Utilities.h"

static const CGFloat kYIndentation = 10.0;

@interface AddFriendViewController () <UITextViewDelegate>

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

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

    [self subscribeNotifications];
    
    [self createScrollView];
    [self createToxIdViews];
    [self createMessageViews];
    [self createSendRequestButton];
    
    self.view.backgroundColor = [UIColor uColorOpaqueWithRed:239 green:239 blue:244];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self adjustSubviews];
}

- (void)dealloc
{
    [self unsubscribeNotifications];
}

#pragma mark -  Notifications

- (void)subscribeNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unsubscribeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -  Actions

- (void)keyboardWillShow
{
    self.scrollView.scrollEnabled = NO;
}

- (void)keyboardWillHide
{
    self.scrollView.scrollEnabled = YES;
    
    [self resignTextViewResponders];
}

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
    [self resignTextViewResponders];
}

#pragma mark -  UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView isEqual:self.messageTextView]) {
        CGPoint offset = CGPointZero;
        offset.y = CGRectGetMinY(self.messageTitleLabel.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame)
                                                               - kYIndentation;
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
    self.toxIdTextView.returnKeyType = UIReturnKeyDone;
    self.toxIdTextView.keyboardType = UIKeyboardTypeNamePhonePad;
    self.toxIdTextView.layer.cornerRadius = 5.0f;
    self.toxIdTextView.layer.borderWidth = 0.5f;
    self.toxIdTextView.layer.borderColor = [[UIColor colorWithWhite:0.8f alpha:1.0f] CGColor];
    [self.scrollView addSubview:self.toxIdTextView];
}

- (void)createMessageViews
{
    self.messageTitleLabel = [self.scrollView addLabelWithTextColor:[UIColor blackColor]
                                                          bgColor:[UIColor clearColor]];
    self.messageTitleLabel.text = NSLocalizedString(@"Message", @"Add friend");

    self.messageTextView = [UITextView new];
    self.messageTextView.delegate = self;
    self.messageTextView.layer.cornerRadius = 5.0f;
    self.messageTextView.layer.borderWidth = 0.5f;
    self.messageTextView.layer.borderColor= [[UIColor colorWithWhite:0.8f alpha:1.0f] CGColor];
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

- (void)resignTextViewResponders
{
    if (self.toxIdTextView.isFirstResponder) {
        [self.toxIdTextView resignFirstResponder];
    }

    if (self.messageTextView.isFirstResponder) {
        [self.messageTextView resignFirstResponder];
    } 
}

- (void)adjustSubviews
{
    self.scrollView.frame = self.view.bounds;

    CGFloat currentOriginY = 0.0;

    CGRect frame = CGRectZero;

    {
        [self.toxIdTitleLabel sizeToFit];
        frame = self.toxIdTitleLabel.frame;
        frame.origin.x = 10.0;
        frame.origin.y = currentOriginY + kYIndentation;
        self.toxIdTitleLabel.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    {
        const CGFloat xIndentation = self.toxIdTitleLabel.frame.origin.x;
        
        [self.toxIdQRButton sizeToFit];
        frame = self.toxIdQRButton.frame;
        frame.origin.x = self.view.bounds.size.width - xIndentation - frame.size.width;
        frame.origin.y = CGRectGetMidY(self.toxIdTitleLabel.frame) - frame.size.height / 2;
        self.toxIdQRButton.frame = frame;
    }

    {
        const CGFloat xIndentation = self.toxIdTitleLabel.frame.origin.x;

        frame = CGRectZero;
        frame.origin.x = xIndentation;
        frame.origin.y = currentOriginY + kYIndentation;
        frame.size.width = self.view.bounds.size.width - 2 * xIndentation;
        frame.size.height = 80.0;
        self.toxIdTextView.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    {
        [self.messageTitleLabel sizeToFit];
        frame = self.messageTitleLabel.frame;
        frame.origin.x = self.toxIdTitleLabel.frame.origin.x;
        frame.origin.y = currentOriginY + kYIndentation;
        self.messageTitleLabel.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    [self.sendRequestButton sizeToFit];
    const CGFloat sendRequestButtonHeight = self.sendRequestButton.frame.size.height;

    {
        const CGFloat xIndentation = self.toxIdTitleLabel.frame.origin.x;

        frame = CGRectZero;
        frame.origin.x = xIndentation;
        frame.origin.y = currentOriginY + kYIndentation;
        frame.size.width = self.view.bounds.size.width - 2 * xIndentation;
        CGFloat height = self.scrollView.bounds.size.height - self.scrollView.contentInset.top -
            self.scrollView.contentInset.bottom - frame.origin.y - sendRequestButtonHeight - 2 * kYIndentation;
        if (height < self.toxIdTextView.frame.size.height) {
            height = roundf(self.toxIdTextView.frame.size.height * 0.7f);
        }
        frame.size.height = height;
        self.messageTextView.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    {
        frame = self.sendRequestButton.frame;
        frame.origin.x = (self.view.bounds.size.width - frame.size.width) / 2;
        frame.origin.y = currentOriginY + kYIndentation;
        self.sendRequestButton.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);

    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.origin.x, currentOriginY + kYIndentation);
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
