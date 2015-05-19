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

static const CGFloat kTextViewIndentationLeft = 45.0;
static const CGFloat kTextViewIndentationRight = 60.0;

@interface ChatInputView() <UITextViewDelegate>

@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *cameraButton;
@property (strong, nonatomic) UIButton *sendButton;

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
        [self createButtons];
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
    [super resignFirstResponder];

    return [self.textView resignFirstResponder];
}

#pragma mark -  Properties

- (void)setButtonsEnabled:(BOOL)enabled
{
    self.cameraButton.enabled = enabled;
    self.sendButton.enabled = enabled;
}

- (BOOL)buttonsEnabled
{
    return self.sendButton.enabled;
}

- (void)setText:(NSString *)text
{
    self.textView.text = text;

    [self.delegate chatInputViewWantsToUpdateFrame:self];
}

- (NSString *)text
{
    return self.textView.text;
}

#pragma mark -  Actions

- (void)cameraButtonPressed
{
    [self.delegate chatInputView:self imageButtonPressedWithText:self.textView.text];
}

- (void)sendButtonPressed
{
    [self.delegate chatInputView:self sendButtonPressedWithText:self.textView.text];
    [self stopTyping];
}

#pragma mark -  Public methods

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

    const CGFloat maxWidth = width - kTextViewIndentationLeft -  kTextViewIndentationRight;

    CGSize size = [text stringSizeWithFont:self.textView.font
                         constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)];

    return size.height + 18.0;
}

- (BOOL)becomeFirstResponder
{
    return [self.textView becomeFirstResponder];
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

    if ([result lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > TOX_MAX_MESSAGE_LENGTH) {
        self.textView.text = [result substringToByteLength:TOX_MAX_MESSAGE_LENGTH
                                             usingEncoding:NSUTF8StringEncoding];
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
    self.textView.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:16];
    self.textView.layer.cornerRadius = 3.0;

    [self addSubview:self.textView];
}

- (void)createButtons
{
    self.cameraButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cameraButton setImage:[UIImage imageNamed:@"chat-camera"] forState:UIControlStateNormal];
    [self.cameraButton addTarget:self action:@selector(cameraButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cameraButton];

    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendButton setTitle:NSLocalizedString(@"Send", @"Settings") forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.sendButton];
}

- (void)adjustSubviews
{
    CGRect frame = self.textView.frame;
    frame.size.width = self.bounds.size.width - kTextViewIndentationLeft - kTextViewIndentationRight;
    frame.size.height = self.bounds.size.height - 8.0;
    frame.origin.x = kTextViewIndentationLeft;
    frame.origin.y = (self.bounds.size.height - frame.size.height) / 2.0;
    self.textView.frame = frame;

    [self.cameraButton sizeToFit];
    frame = self.cameraButton.frame;
    frame.origin.x = 10.0;
    frame.origin.y = (self.frame.size.height - frame.size.height) / 2;
    self.cameraButton.frame = frame;

    [self.sendButton sizeToFit];
    frame = self.sendButton.frame;
    frame.origin.x = self.frame.size.width - frame.size.width - 10.0;
    frame.origin.y = (self.frame.size.height - frame.size.height) / 2;
    self.sendButton.frame = frame;
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
