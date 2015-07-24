//
//  ContentCellWithTitle.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 19/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "ContentCellWithTitle.h"
#import "AppearanceManager.h"
#import "NSString+Utilities.h"

static const CGFloat kTitleHeight = 20.0;
static const CGFloat kTextTopOffset = 2.0;

@interface ContentCellWithTitle () <UITextViewDelegate>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UITextView *textView;

@property (assign, nonatomic) UIEdgeInsets defaultTextViewInsets;
@property (assign, nonatomic) CGFloat defaultTextViewLineFragmentPadding;

@end

@implementation ContentCellWithTitle

#pragma mark -  Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (! self) {
        return nil;
    }

    [self createViews];
    [self installConstraints];

    self.editable = NO;

    return self;
}

#pragma mark -  Properties

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setButtonTitle:(NSString *)title
{
    [self.button setTitle:title forState:UIControlStateNormal];
}

- (NSString *)buttonTitle
{
    return [self.button titleForState:UIControlStateNormal];
}

- (void)setMainText:(NSString *)text
{
    self.textView.text = text;
}

- (NSString *)mainText
{
    return self.textView.text;
}

- (void)setEditable:(BOOL)editable
{
    self.textView.editable = editable;

    if (editable) {
        self.textView.layer.borderColor = [[UIColor colorWithWhite:0.8f alpha:1.0f] CGColor];
        self.textView.textContainerInset = self.defaultTextViewInsets;
        self.textView.textContainer.lineFragmentPadding = self.defaultTextViewLineFragmentPadding;
    }
    else {
        self.textView.layer.borderColor = [[UIColor clearColor] CGColor];
        self.textView.textContainerInset = UIEdgeInsetsZero;
        self.textView.textContainer.lineFragmentPadding = 0;
    }
}

- (BOOL)editable
{
    return self.textView.editable;
}

#pragma mark -  Actions

- (void)buttonPressed
{
    [self.delegate contentCellWithTitleDidPressButton:self];
}

#pragma mark -  UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    if (! self.maxMainTextLength) {
        return YES;
    }

    NSString *resultText = [textView.text stringByReplacingCharactersInRange:range withString:text];

    if ([resultText lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > self.maxMainTextLength) {
        textView.text = [resultText substringToByteLength:self.maxMainTextLength usingEncoding:NSUTF8StringEncoding];

        return NO;
    }

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(contentCellWithTitleWantsToResize:)]) {
        [self.delegate contentCellWithTitleWantsToResize:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(contentCellWithTitle:didChangeMainText:)]) {
        [self.delegate contentCellWithTitle:self didChangeMainText:textView.text];
    }
}

#pragma mark -  Private

- (void)createViews
{
    UIColor *textMainColor = [[AppContext sharedContext].appearance textMainColor];

    self.titleLabel = [UILabel new];
    self.titleLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueLightWithSize:17.0];
    self.titleLabel.textColor = textMainColor;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self.customContentView addSubview:self.titleLabel];

    self.button = [UIButton new];
    [self.button setTitleColor:textMainColor forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.customContentView addSubview:self.button];

    self.textView = [UITextView new];
    self.textView.delegate = self;
    self.textView.scrollEnabled = NO;
    self.textView.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:17.0];
    self.textView.textColor = [UIColor blackColor];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.returnKeyType = UIReturnKeyDone;
    self.textView.layer.cornerRadius = 5.0;
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.masksToBounds = YES;
    [self.customContentView addSubview:self.textView];

    self.defaultTextViewInsets = self.textView.textContainerInset;
    self.defaultTextViewLineFragmentPadding = self.textView.textContainer.lineFragmentPadding;
}

- (void)installConstraints
{
    [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.customContentView);
        make.height.equalTo(kTitleHeight);
    }];

    [self.button makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.titleLabel.right);
        make.right.equalTo(self.customContentView);
        make.centerY.equalTo(self.titleLabel);
    }];

    [self.textView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.bottom).offset(kTextTopOffset);
        make.left.right.bottom.equalTo(self.customContentView);
    }];
}

@end
