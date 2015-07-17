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

- (void)loadWhiteView
{
    [self utilities_loadView];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)loadLightGrayView
{
    [self utilities_loadView];
    self.view.backgroundColor = [[AppContext sharedContext].appearance lightGrayBackground];
}

#pragma mark -  Private

- (void)utilities_loadView
{
    CGRect frame = CGRectZero;
    frame.size = [[UIScreen mainScreen] applicationFrame].size;

    self.view = [[UIView alloc] initWithFrame:frame];
}

@end
