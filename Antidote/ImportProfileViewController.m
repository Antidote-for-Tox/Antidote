//
//  ImportProfileViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 09/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ImportProfileViewController.h"
#import "UIViewController+Utilities.h"
#import "AppearanceManager.h"

@interface ImportProfileViewController ()

@end

@implementation ImportProfileViewController

- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    self.title = NSLocalizedString(@"Import Profile", @"ImportProfileViewController");

    return self;
}

- (void)loadView
{
    [self loadViewWithBackgroundColor:[[AppContext sharedContext].appearance textMainColor]];
}

@end
