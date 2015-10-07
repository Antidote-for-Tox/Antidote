//
//  ViewPassingGestures.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 28.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ViewPassingGestures.h"

@implementation ViewPassingGestures

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *subview in self.subviews) {
        if ([subview hitTest:[self convertPoint:point toView:subview] withEvent:event] != nil) {
            return YES;
        }
    }
    return NO;
}

@end
