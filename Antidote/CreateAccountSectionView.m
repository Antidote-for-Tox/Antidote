//
//  CreateAccountSectionView.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 09/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "CreateAccountSectionView.h"
#import "AppearanceManager.h"
#import "NSString+Utilities.h"

static const CGFloat kTextFieldHeight = 40.0;
static const CGFloat kVerticalOffset = 5.0;

@interface CreateAccountSectionView () <UITextFieldDelegate>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UILabel *hintLabel;

@end

@implementation CreateAccountSectionView

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    [self createViews];
    [self installConstraints];

    return self;
}

#pragma mark -  Properties

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    self.textField.placeholder = placeholder;
}

- (NSString *)placeholder
{
    return self.textField.placeholder;
}

- (NSString *)text
{
    return self.textField.text;
}

- (void)setText:(NSString *)text
{
    self.textField.text = text;
}

- (NSString *)hint
{
    return self.hintLabel.text;
}

- (void)setHint:(NSString *)hint
{
    self.hintLabel.text = hint;
}

- (void)setReturnKeyType:(UIReturnKeyType)type
{
    self.textField.returnKeyType = type;
}

- (UIReturnKeyType)returnKeyType
{
    return self.textField.returnKeyType;
}

#pragma mark -  Public

- (BOOL)becomeFirstResponder
{
    return [self.textField becomeFirstResponder];
}

#pragma mark -  UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [self.delegate createAccountSectionViewShouldReturn:self];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (! self.maxTextUTF8Length) {
        return YES;
    }

    NSString *resultText = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if ([resultText lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > self.maxTextUTF8Length) {
        textField.text = [resultText substringToByteLength:self.maxTextUTF8Length usingEncoding:NSUTF8StringEncoding];

        return NO;
    }

    return YES;
}

#pragma mark -  Private

- (void)createViews
{
    self.titleLabel = [UILabel new];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:18.0];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.titleLabel];

    self.textField = [UITextField new];
    self.textField.delegate = self;
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.textField.enablesReturnKeyAutomatically = YES;
    [self addSubview:self.textField];

    self.hintLabel = [UILabel new];
    self.hintLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    self.hintLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueLightWithSize:14.0];
    self.hintLabel.numberOfLines = 0;
    self.hintLabel.textColor = [UIColor whiteColor];
    self.hintLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.hintLabel];
}

- (void)installConstraints
{
    [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.right.equalTo(self);
    }];

    [self.textField makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.bottom).offset(kVerticalOffset);
        make.left.right.equalTo(self);
        make.height.equalTo(kTextFieldHeight);
    }];

    [self.hintLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textField.bottom).offset(kVerticalOffset);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

@end
