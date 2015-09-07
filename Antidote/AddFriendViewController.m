//
//  AddFriendViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 30/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <BlocksKit/UIAlertView+BlocksKit.h>
#import <Masonry/Masonry.h>
#import <SDCAlertView/SDCAlertController.h>
#import <UITextView+Placeholder/UITextView+Placeholder.h>

#import <objcTox/OCTSubmanagerFriends.h>

#import "AddFriendViewController.h"
#import "QRScannerController.h"
#import "AppearanceManager.h"
#import "Helper.h"
#import "UIViewController+Utilities.h"
#import "NSString+Utilities.h"
#import "ErrorHandler.h"
#import "RunningContext.h"

static const CGFloat kTextViewTopOffset = 5.0;
static const CGFloat kTextViewXOffset = 5.0;
static const CGFloat kQrCodeBottomSpacerDeltaHeight = 70.0;

static const CGFloat kSendAlertTextViewXOffset = 5.0;
static const CGFloat kSendAlertTextViewBottomOffset = -10.0;
static const CGFloat kSendAlertTextViewHeight = 70.0;

@interface AddFriendViewController () <UITextViewDelegate>

@property (strong, nonatomic) UITextView *textView;

@property (strong, nonatomic) UIView *orTopSpacer;
@property (strong, nonatomic) UIView *qrCodeBottomSpacer;

@property (strong, nonatomic) UILabel *orLabel;
@property (strong, nonatomic) UIButton *qrCodeButton;

@property (strong, nonatomic) NSString *cachedMessage;

@end

@implementation AddFriendViewController

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    self.title = NSLocalizedString(@"Add Friend", @"Add Friend");

    return self;
}

- (void)loadView
{
    [self loadWhiteView];

    [self createViews];
    [self installConstraints];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Add Friend")
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(sendButtonPressed)];
    [self updateSendButton];
}

#pragma mark -  Actions

- (void)qrCodeButtonPressed
{
    UINavigationController *navCon =
        [QRScannerController navigationWithScannerControllerWithSuccess:^(QRScannerController *controller, NSArray *stringValues) {
        [self processQRStringValues:stringValues fromController:controller];

    } cancelBlock:^(QRScannerController *controller) {

        [self dismissViewControllerAnimated:YES completion:nil];
    }];

    [self presentViewController:navCon animated:YES completion:nil];
}

- (void)sendButtonPressed
{
    [self.textView resignFirstResponder];
    weakself;

    UITextView *textView = [UITextView new];
    textView.text = self.cachedMessage;
    textView.placeholder = NSLocalizedString(@"Hello! Could you please add me to your friendlist?", @"Add Friend");
    textView.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:17.0];
    textView.layer.cornerRadius = 5.0;
    textView.layer.masksToBounds = YES;

    SDCAlertController *alert = [SDCAlertController alertControllerWithTitle:NSLocalizedString(@"Message", @"Add Friend")
                                                                     message:nil
                                                              preferredStyle:SDCAlertControllerStyleAlert];

    [alert.contentView addSubview:textView];
    [textView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(alert.contentView);
        make.bottom.equalTo(alert.contentView).offset(kSendAlertTextViewBottomOffset);
        make.left.equalTo(alert.contentView).offset(kSendAlertTextViewXOffset);
        make.right.equalTo(alert.contentView).offset(-kSendAlertTextViewXOffset);
        make.height.equalTo(kSendAlertTextViewHeight);
    }];

    [alert addAction:[SDCAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Add Friend")
                                               style:SDCAlertActionStyleDefault
                                             handler:nil]];

    [alert addAction:[SDCAlertAction actionWithTitle:NSLocalizedString(@"Send", @"Add Friend")
                                               style:SDCAlertActionStyleRecommended
                                             handler:^(SDCAlertAction *action) {
        strongself;

        self.cachedMessage = textView.text;

        OCTSubmanagerFriends *submanager = [RunningContext context].toxManager.friends;
        NSString *message = textView.text.length ? textView.text : textView.placeholder;
        NSError *error;

        if (! [submanager sendFriendRequestToAddress:self.textView.text message:message error:&error]) {
            [[AppContext sharedContext].errorHandler handleError:error type:ErrorHandlerTypeSendFriendRequest];
            return;
        }

        [self.navigationController popViewControllerAnimated:YES];
    }]];

    [alert presentWithCompletion:nil];
}

#pragma mark -  UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    NSString *resultText = [textView.text stringByReplacingCharactersInRange:range withString:text];

    if ([resultText lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > kOCTToxAddressLength) {
        textView.text = [resultText substringToByteLength:kOCTToxAddressLength usingEncoding:NSUTF8StringEncoding];

        return NO;
    }

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateSendButton];
}

#pragma mark -  Private

- (void)createViews
{
    self.textView = [UITextView new];
    self.textView.placeholder = NSLocalizedString(@"Enter Tox ID", @"Add Friend");
    self.textView.delegate = self;
    self.textView.scrollEnabled = NO;
    self.textView.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:17.0];
    self.textView.textColor = [UIColor blackColor];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.returnKeyType = UIReturnKeyDone;
    self.textView.layer.cornerRadius = 5.0;
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    self.textView.layer.masksToBounds = YES;
    [self.view addSubview:self.textView];

    self.orTopSpacer = [self createSpacer];
    self.qrCodeBottomSpacer = [self createSpacer];

    self.orLabel = [UILabel new];
    self.orLabel.text = NSLocalizedString(@"or", @"Add Friend");
    self.orLabel.textColor = [UIColor blackColor];
    self.orLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.orLabel];

    self.qrCodeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.qrCodeButton setTitle:NSLocalizedString(@"Use QR code", @"Add Friend") forState:UIControlStateNormal];
    self.qrCodeButton.titleLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueBoldWithSize:16.0];
    [self.qrCodeButton addTarget:self action:@selector(qrCodeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.qrCodeButton];
}

- (void)installConstraints
{
    [self.textView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kTextViewTopOffset);
        make.left.equalTo(self.view).offset(kTextViewXOffset);
        make.right.equalTo(self.view).offset(-kTextViewXOffset);
        make.bottom.equalTo(self.view.centerY);
    }];

    [self.orTopSpacer makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textView.bottom);
        make.left.right.equalTo(self.view);
    }];

    [self.orLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.orTopSpacer.bottom);
        make.centerX.equalTo(self.view);
    }];

    [self.qrCodeButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.orLabel.bottom);
        make.centerX.equalTo(self.view);
    }];

    [self.qrCodeBottomSpacer makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.qrCodeButton.bottom);
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(self.orTopSpacer).offset(kQrCodeBottomSpacerDeltaHeight);
    }];
}

- (UIView *)createSpacer
{
    UIView *spacer = [UIView new];
    spacer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:spacer];

    return spacer;
}

- (void)processQRStringValues:(NSArray *)stringValues fromController:(QRScannerController *)controller
{
    NSString *goodString = nil;

    for (NSString *originalString in stringValues) {
        NSString *string = [originalString uppercaseString];
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        NSString *toxPrefix = @"TOX:";

        if ([string hasPrefix:toxPrefix] && (string.length > toxPrefix.length)) {
            string = [string substringFromIndex:toxPrefix.length];
        }

        if ([Helper isAddressString:string]) {
            goodString = string;
            break;
        }
    }

    if (goodString) {
        self.textView.text = goodString;
        [self updateSendButton];

        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        NSString *message = [NSString stringWithFormat:
                             NSLocalizedString(@"Wrong code. It should contain Tox ID, but contains %@", @"Add Friend"),
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

- (void)updateSendButton
{
    self.navigationItem.rightBarButtonItem.enabled = [Helper isAddressString:self.textView.text];
}

@end
