//
//  LoginViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <objcTox/OCTManagerConfiguration.h>
#import <objcTox/OCTManager.h>

#import "LoginViewController.h"
#import "LifecycleManager.h"
#import "LifecyclePhaseLogin.h"
#import "ProfileManager.h"

static NSString *const kProfileName = @"profile";

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Login" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    [button makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

- (void)buttonPressed
{
    LifecyclePhaseLogin *phase = (LifecyclePhaseLogin *)[[AppContext sharedContext].lifecycleManager currentPhase];

    NSAssert([phase isKindOfClass:[LifecyclePhaseLogin class]],
             @"Something went terrible wrong, we should be in login phase");

    ProfileManager *profileManager = [ProfileManager new];

    if (! [profileManager.allProfiles containsObject:kProfileName]) {
        [profileManager createProfileWithName:kProfileName error:nil];
    }

    OCTManagerConfiguration *configuration = [profileManager configurationForProfileWithName:kProfileName];
    OCTManager *manager = [[OCTManager alloc] initWithConfiguration:configuration error:nil];

    [phase finishPhaseWithToxManager:manager];
}

@end
