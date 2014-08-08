//
//  ChatInputView.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 28.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ChatInputView.h"
#import "UIColor+Utilities.h"
#import "NSString+Utilities.h"
#import "ToxManager.h"

static const CGFloat kTypingTimerInterval = 5.0;

static const CGFloat kTextViewDeltaWidth = 60.0;

@interface ChatInputView() <UITextViewDelegate>

@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *button;

@property (strong, nonatomic) NSTimer *typingTimer;

@end

@implementation ChatInputView

#pragma mark -  Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        self.backgroundColor = [UIColor uColorOpaqueWithWhite:236];

        [self createTextView];
        [self createButton];
        [self adjustSubviews];
    }

    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

    [self adjustSubviews];
}

- (BOOL)resignFirstResponder
{
    return [self.textView resignFirstResponder];
}

#pragma mark -  Properties

- (void)setSendButtonEnabled:(BOOL)enabled
{
    self.button.enabled = enabled;
}

- (BOOL)sendButtonEnabled
{
    return self.button.enabled;
}

#pragma mark -  Actions

- (void)buttonPressed
{
    [self.delegate chatInputView:self sendButtonPressedWithText:self.textView.text];
    [self stopTyping];
}

#pragma mark -  Public methods

- (void)setText:(NSString *)text
{
    self.textView.text = nil;

    [self.delegate chatInputViewWantsToUpdateFrame:self];
}

- (CGFloat)heightWithCurrentTextAndWidth:(CGFloat)width
{
    NSString *text = self.textView.text;

    if (! text.length) {
        text = @"pl";
    }

    if ([text hasSuffix:@"\n"]) {
        // add character on new line for right size computation
        text = [text stringByAppendingString:@"s"];
    }

    CGSize size = [text stringSizeWithFont:self.textView.font
                         constrainedToSize:CGSizeMake(width - kTextViewDeltaWidth, CGFLOAT_MAX)];

    return size.height + 18.0;
}

#pragma mark -  UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self startTyping];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self stopTyping];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    BOOL answer = YES;

    NSString *result = [textView.text stringByReplacingCharactersInRange:range withString:text];

    if (result.length > TOX_MAX_MESSAGE_LENGTH) {
        self.textView.text = [result substringToIndex:TOX_MAX_MESSAGE_LENGTH];
        answer = NO;
    }

    return answer;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self startTyping];

    const CGFloat height = [self heightWithCurrentTextAndWidth:self.frame.size.width];

    if (height != self.frame.size.height) {
        [self.delegate chatInputViewWantsToUpdateFrame:self];
    }
}

#pragma mark -  Private methods

- (void)createTextView
{
    self.textView = [UITextView new];
    self.textView.delegate = self;
    self.textView.textColor = [UIColor blackColor];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.font = [AppearanceManager fontHelveticaNeueWithSize:16];
    self.textView.layer.cornerRadius = 3.0;

    [self addSubview:self.textView];
}

- (void)createButton
{
    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.button setTitle:NSLocalizedString(@"Send", @"Settings") forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.button];
}

- (void)adjustSubviews
{
    CGRect frame = self.textView.frame;
    frame.size.width = self.bounds.size.width - kTextViewDeltaWidth;
    frame.size.height = self.bounds.size.height - 8.0;
    frame.origin.x = 5.0;
    frame.origin.y = (self.bounds.size.height - frame.size.height) / 2.0;
    self.textView.frame = frame;

    [self.button sizeToFit];
    frame = self.button.frame;
    frame.origin.x = self.frame.size.width - frame.size.width - 10.0;
    frame.origin.y = (self.frame.size.height - frame.size.height) / 2;
    self.button.frame = frame;
}

- (void)startTyping
{
    @synchronized(self) {
        if (self.typingTimer) {
            [self.typingTimer invalidate];
            self.typingTimer = nil;
        }

        self.typingTimer = [NSTimer scheduledTimerWithTimeInterval:kTypingTimerInterval
                                                            target:self
                                                          selector:@selector(stopTyping)
                                                          userInfo:nil
                                                           repeats:NO];

        [self.delegate chatInputView:self typingChangedTo:YES];
    }
}

- (void)stopTyping
{
    @synchronized(self) {
        if (self.typingTimer) {
            [self.typingTimer invalidate];
            self.typingTimer = nil;
        }

        [self.delegate chatInputView:self typingChangedTo:NO];
    }
}

@end
