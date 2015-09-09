//
//  CreateAccountViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 09/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "UIViewController+Utilities.h"
#import "AppearanceManager.h"

@interface CreateAccountViewController ()

@end

@implementation CreateAccountViewController

- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    self.title = NSLocalizedString(@"Create Account", @"CreateAccountViewController");

    return self;
}

- (void)loadView
{
    [self loadViewWithBackgroundColor:[[AppContext sharedContext].appearance textMainColor]];
}

@end
