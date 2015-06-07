//
//  AppContext.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 19.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "AppContext.h"
#import "AppearanceManager.h"
#import "EventsManager.h"
#import "ProfileManager.h"
#import "UserDefaultsManager.h"

@interface AppContext()

@property (strong, nonatomic, readwrite) AppearanceManager *appearance;
@property (strong, nonatomic, readwrite) EventsManager *events;
@property (strong, nonatomic, readwrite) ProfileManager *profileManager;
@property (strong, nonatomic, readwrite) UserDefaultsManager *userDefaults;

@end

@implementation AppContext

#pragma mark -  Lifecycle

- (id)init
{
    return nil;
}

- (id)initPrivate
{
    self = [super init];

    if (! self) {
        return nil;
    }

    _userDefaults = [UserDefaultsManager new];
    [self createUserDefaultsValuesAndRewrite:NO];

    _events = [EventsManager new];
    _profileManager = [ProfileManager new];

    [self createAppearance];

    return self;
}

+ (instancetype)sharedContext
{
    static AppContext *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[AppContext alloc] initPrivate];
    });

    return instance;
}

#pragma mark -  Public

- (void)restoreDefaultSettings
{
    [self createUserDefaultsValuesAndRewrite:YES];
}

- (void)recreateAppearance
{
    self.appearance = nil;
    [self createAppearance];
}

#pragma mark -  Private

- (void)createUserDefaultsValuesAndRewrite:(BOOL)rewrite
{
    if (rewrite || ! self.userDefaults.uShowMessageInLocalNotification) {
        self.userDefaults.uShowMessageInLocalNotification = @(YES);
    }

    if (rewrite || ! self.userDefaults.uIpv6Enabled) {
        self.userDefaults.uIpv6Enabled = @(1);
    }

    if (rewrite || ! self.userDefaults.uUDPEnabled) {
        self.userDefaults.uUDPEnabled = @(0);
    }

    if (rewrite || ! self.userDefaults.uCurrentColorscheme) {
        self.userDefaults.uCurrentColorscheme = @(AppearanceManagerColorschemeRed);
    }
}

- (void)createAppearance
{
    AppearanceManagerColorscheme colorscheme = _userDefaults.uCurrentColorscheme.unsignedIntegerValue;
    self.appearance = [[AppearanceManager alloc] initWithColorscheme:colorscheme];
}

@end
