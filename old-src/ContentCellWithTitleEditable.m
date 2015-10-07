//
//  ContentCellWithTitleEditable.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 25/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "ContentCellWithTitleEditable.h"
#import "AppearanceManager.h"
#import "NSString+Utilities.h"

static const CGFloat kTextTopOffset = 2.0;

@interface ContentCellWithTitleEditable () <UITextViewDelegate>

@property (strong, nonatomic) UITextView *textView;

@end

@implementation ContentCellWithTitleEditable
@dynamic delegate;

#pragma mark -  Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (! self) {
        return nil;
    }

    [self createViews];
    [self installConstraints];

    return self;
}

#pragma mark -  Properties

- (void)setMainText:(NSString *)mainText
{
    self.textView.text = mainText;
}

- (NSString *)mainText
{
    return self.textView.text;
}

#pragma mark -  Override

- (void)resetCell
{
    [super resetCell];

    self.maxMainTextLength = 0;
}

#pragma mark -  Public

- (void)startEditing
{
    [self.textView becomeFirstResponder];
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

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(contentCellWithTitleEditableDidBeginEditing:)]) {
        [self.delegate contentCellWithTitleEditableDidBeginEditing:self];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGSize size  = textView.frame.size;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)];

    // Resize cell only when cell's size is changes
    if (size.height == newSize.height) {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(contentCellWithTitleEditableWantsToResize:)]) {
        [self.delegate contentCellWithTitleEditableWantsToResize:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(contentCellWithTitleEditableDidEndEditing:)]) {
        [self.delegate contentCellWithTitleEditableDidEndEditing:self];
    }
}

#pragma mark -  Private

- (void)createViews
{
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
}

- (void)installConstraints
{
    [self.textView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.bottom).offset(kTextTopOffset);
        make.left.right.bottom.equalTo(self.customContentView);
    }];
}

@end
