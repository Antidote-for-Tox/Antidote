//
//  FullscreenSpinner.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 10/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "FullscreenSpinner.h"
#import "AppearanceManager.h"

@implementation FullscreenSpinner

- (void)showInView:(UIView *)view
{
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.color = [[AppContext sharedContext].appearance textMainColor];
    [self addSubview:spinner];
    [spinner startAnimating];

    [spinner makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];

    [view addSubview:self];

    [self makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
}

- (void)remove
{
    [self removeFromSuperview];
}

@end
