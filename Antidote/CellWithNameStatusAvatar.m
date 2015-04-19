//
//  CellWithNameStatusAvatar.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 12.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CellWithNameStatusAvatar.h"
#import "NSString+Utilities.h"

@interface CellWithNameStatusAvatar() <UITextFieldDelegate>

@property (strong, nonatomic) UIButton *avatarButton;
@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UITextField *statusMessageField;

@end

@implementation CellWithNameStatusAvatar

#pragma mark -  Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createImageView];
        [self createTextFields];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self adjustSubviews];
}

#pragma mark -  Actions

- (void)avatarButtonPressed
{
    [self.delegate cellWithNameStatusAvatarAvatarButtonPressed:self];
}

#pragma mark -  Public

- (void)redraw
{
    [self.avatarButton setImage:self.avatarImage forState:UIControlStateNormal];
    self.nameField.text = self.name;
    self.statusMessageField.text = self.statusMessage;

    [self adjustSubviews];
}

+ (CGFloat)height
{
    return 75.0;
}

+ (CGFloat)avatarHeight
{
    return 55.0;
}

#pragma mark -  UITextFieldDelegate

- (BOOL)             textField:(UITextField *)textField
 shouldChangeCharactersInRange:(NSRange)range
             replacementString:(NSString *)string
{
    NSString *resultText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSUInteger maxLength = NSUIntegerMax;

    if ([textField isEqual:self.nameField]) {
        maxLength = self.maxNameLength;
    }
    else if ([textField isEqual:self.statusMessageField]) {
        maxLength = self.maxStatusMessageLength;
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
        [self.delegate cellWithNameStatusAvatar:self nameChangedTo:textField.text];
    }
    else if ([textField isEqual:self.statusMessageField]) {
        [self.delegate cellWithNameStatusAvatar:self statusMessageChangedTo:textField.text];
    }
}

#pragma mark -  Private

- (void)createImageView
{
    CGRect frame = CGRectZero;
    frame.size.width = frame.size.height = [CellWithNameStatusAvatar avatarHeight];

    self.avatarButton = [[UIButton alloc] initWithFrame:frame];
    self.avatarButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.avatarButton addTarget:self
                          action:@selector(avatarButtonPressed)
                forControlEvents:UIControlEventTouchUpInside];
    self.avatarButton.layer.cornerRadius = frame.size.width / 2;
    self.avatarButton.layer.masksToBounds = YES;
    [self.contentView addSubview:self.avatarButton];
}

- (void)createTextFields
{
    self.nameField = [UITextField new];
    self.nameField.delegate = self;
    self.nameField.placeholder = NSLocalizedString(@"Name", @"Settings");
    self.nameField.borderStyle = UITextBorderStyleRoundedRect;
    self.nameField.returnKeyType = UIReturnKeyDone;
    self.nameField.font = [AppearanceManager fontHelveticaNeueWithSize:18];
    [self.contentView addSubview:self.nameField];

    self.statusMessageField = [UITextField new];
    self.statusMessageField.delegate = self;
    self.statusMessageField.placeholder = NSLocalizedString(@"Status", @"Settings");
    self.statusMessageField.borderStyle = UITextBorderStyleRoundedRect;
    self.statusMessageField.returnKeyType = UIReturnKeyDone;
    self.statusMessageField.font = [AppearanceManager fontHelveticaNeueWithSize:16];
    [self.contentView addSubview:self.statusMessageField];
}

- (void)adjustSubviews
{
    const CGFloat xIndentation = 10.0;
    const CGFloat yIndentation = 5.0;

    CGRect frame = self.avatarButton.frame;
    frame.origin.x = xIndentation;
    frame.origin.y = (self.bounds.size.height - frame.size.height) / 2;
    self.avatarButton.frame = frame;

    frame = CGRectZero;
    frame.size.width = self.bounds.size.width - CGRectGetMaxX(self.avatarButton.frame) - 2 * xIndentation;
    frame.size.height = 30.0;
    frame.origin.x = self.bounds.size.width - frame.size.width - xIndentation;
    frame.origin.y = yIndentation;
    self.nameField.frame = frame;

    frame = self.nameField.frame;
    frame.origin.y = self.bounds.size.height - frame.size.height - yIndentation;
    self.statusMessageField.frame = frame;
}

@end
