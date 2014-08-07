//
//  ChatInputView.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 28.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ChatInputView.h"
#import "UIColor+Utilities.h"

static const CGFloat kTypingTimerInterval = 5.0;

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
}

- (CGFloat)heightWithCurrentText
{
    return 40.0;
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

- (void)textViewDidChange:(UITextView *)textView
{
    [self startTyping];
}

#pragma mark -  Private methods

- (void)createTextView
{
    self.textView = [UITextView new];
    self.textView.delegate = self;
    self.textView.textColor = [UIColor blackColor];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.scrollEnabled = NO;

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
    frame.size.width = self.bounds.size.width - 60.0;
    frame.size.height = self.bounds.size.height - 4.0;
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
