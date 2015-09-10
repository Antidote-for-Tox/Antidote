//
//  UIButton+Utilities.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 10/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "UIButton+Utilities.h"
#import "AppearanceManager.h"
#import "UIImage+Utilities.h"

@implementation UIButton (Utilities)

+ (instancetype)loginButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueBoldWithSize:18.0];
    button.layer.cornerRadius = 5.0;
    button.layer.masksToBounds = YES;

    UIColor *bgColor = [[AppContext sharedContext].appearance loginButtonColor];
    UIImage *bgImage = [UIImage imageWithColor:bgColor size:CGSizeMake(1.0, 1.0)];
    [button setBackgroundImage:bgImage forState:UIControlStateNormal];

    return button;
}

@end
