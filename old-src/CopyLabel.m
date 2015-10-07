//
//  CopyLabel.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CopyLabel.h"
#import "AppDelegate.h"

@interface CopyLabel ()

@property (strong, nonatomic) UITapGestureRecognizer *recognizer;

@end

@implementation CopyLabel

#pragma mark -  Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;

        self.recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(tapGesture:)];

        [self addGestureRecognizer:self.recognizer];

        self.copyable = YES;
    }
    return self;
}

#pragma mark -  Properties

- (void)setCopyable:(BOOL)copyable
{
    self.recognizer.enabled = copyable;
}

- (BOOL)copyable
{
    return self.recognizer.enabled;
}

#pragma mark -  Gestures

- (void)tapGesture:(UITapGestureRecognizer *)tapGR
{
    // This fixes issue with calling UIMenuController after UIActionSheet was presented.
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.window makeKeyWindow];

    [self becomeFirstResponder];

    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.frame inView:self.superview];
    [menu setMenuVisible:YES animated:YES];
}

#pragma mark -  Private

- (void)copy:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.text;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end
