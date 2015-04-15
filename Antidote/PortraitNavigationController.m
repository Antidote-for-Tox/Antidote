//
//  PortraitViewController.m
//  Antidote
//
//  Created by Nicholas Palamar on 4/15/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "PortraitNavigationController.h"

@implementation PortraitNavigationController

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
