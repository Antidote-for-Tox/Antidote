//
//  CopyLabel.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CopyLabel.h"

@implementation CopyLabel

#pragma mark -  Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;

        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(tapGesture:)];

        [self addGestureRecognizer:tapGR];
    }
    return self;
}

#pragma mark -  Gestures

- (void)tapGesture:(UITapGestureRecognizer *)tapGR
{
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
