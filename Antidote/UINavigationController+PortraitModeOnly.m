//
//  UINavigationController+PortraitModeOnly.m
//  Antidote
//
//  Created by Nikolay Palamar on 12/04/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "UINavigationController+PortraitModeOnly.h"

@implementation UINavigationController (PortraitModeOnly)

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end