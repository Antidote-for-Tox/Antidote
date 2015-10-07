//
//  KeyboardNotificationController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 10/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "KeyboardNotificationController.h"

@interface KeyboardNotificationController ()

@end

@implementation KeyboardNotificationController

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -  Public

- (void)keyboardWillShowAnimated:(NSNotification *)keyboardNotification
{
    // nop
}

- (void)keyboardWillHideAnimated:(NSNotification *)keyboardNotification
{
    // nop
}

#pragma mark -  Notifications

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    weakself;
    [self performAnimatedBlock:^{
        strongself;
        [self keyboardWillShowAnimated:notification];
    } withKeyboardNotification:notification];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    weakself;
    [self performAnimatedBlock:^{
        strongself;
        [self keyboardWillHideAnimated:notification];
    } withKeyboardNotification:notification];
}

#pragma mark -  Private

- (void)performAnimatedBlock:(void (^)())block withKeyboardNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];

    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];

    UIViewAnimationOptions options = 0;

    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            options |= UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            options |= UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options |= UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            options |= UIViewAnimationOptionCurveLinear;
            break;
    }

    [UIView animateWithDuration:duration delay:0.0 options:options animations:block completion:nil];
}

@end
