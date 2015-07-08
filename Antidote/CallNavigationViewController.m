//
//  CallNavigationControllerViewController.m
//  Antidote
//
//  Created by Chuong Vu on 7/7/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "CallNavigationViewController.h"

#import "Masonry.h"

@interface CallNavigationViewController ()

@end

@implementation CallNavigationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    self.navigationBarHidden = YES;

    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.view.bounds;

    [self.view insertSubview:visualEffectView atIndex:0];

    [visualEffectView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

@end
