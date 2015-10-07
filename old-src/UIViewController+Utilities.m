//
//  UIViewController+Utilities.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "UIViewController+Utilities.h"
#import "AppearanceManager.h"

@implementation UIViewController (Utilities)

#pragma mark -  Public

- (void)loadViewWithBackgroundColor:(UIColor *)color
{
    CGRect frame = CGRectZero;
    frame.size = [[UIScreen mainScreen] applicationFrame].size;

    self.view = [[UIView alloc] initWithFrame:frame];

    self.view.backgroundColor = color;
}

- (void)loadWhiteView
{
    [self loadViewWithBackgroundColor:[UIColor whiteColor]];
}

- (void)loadLightGrayView
{
    [self loadViewWithBackgroundColor:[[AppContext sharedContext].appearance lightGrayBackground]];
}

@end
