//
//  NotificationViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 28.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "NotificationViewController.h"

@interface NotificationViewController ()

@end

@implementation NotificationViewController

- (void)viewWillLayoutSubviews
{
    [self.delegate viewWillLayoutSubviews];
    [super viewWillLayoutSubviews];
}

@end
