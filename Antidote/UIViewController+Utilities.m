//
//  UIViewController+Utilities.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "UIViewController+Utilities.h"
#import "UIColor+Utilities.h"

@implementation UIViewController (Utilities)

- (void)loadWhiteView
{
    CGRect frame = CGRectZero;
    frame.size = [[UIScreen mainScreen] applicationFrame].size;

    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setupNavBarAppearance
{
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor uColorWithWhite:248 alpha:1.0f];
}

@end
