//
//  AppContext.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 19.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "AppContext.h"
#import "AppearanceManager.h"
#import "AvatarsManager.h"
#import "ErrorHandler.h"
#import "FileManager.h"
#import "LifecycleManager.h"
#import "UserDefaultsManager.h"
#import "AppDelegate.h"
#import "Helper.h"
#import "FriendsViewController.h"

@interface AppContext ()

@property (strong, nonatomic, readwrite) AppearanceManager *appearance;
@property (strong, nonatomic, readwrite) AvatarsManager *avatars;
@property (strong, nonatomic, readwrite) ErrorHandler *errorHandler;
@property (strong, nonatomic, readwrite) FileManager *fileManager;
@property (strong, nonatomic, readwrite) LifecycleManager *lifecycleManager;
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

#pragma mark -  Properties

- (AppearanceManager *)appearance
{
    if (_appearance) {
        return _appearance;
    }

    AppearanceManagerColorscheme colorscheme = self.userDefaults.uCurrentColorscheme.unsignedIntegerValue;
    _appearance = [[AppearanceManager alloc] initWithColorscheme:colorscheme];

    return _appearance;
}

- (AvatarsManager *)avatars
{
    if (_avatars) {
        return _avatars;
    }

    _avatars = [AvatarsManager new];

    return _avatars;
}

- (ErrorHandler *)errorHandler
{
    if (_errorHandler) {
        return _errorHandler;
    }

    _errorHandler = [ErrorHandler new];

    return _errorHandler;
}

- (FileManager *)fileManager
{
    if (_fileManager) {
        return _fileManager;
    }

    _fileManager = [FileManager new];

    return _fileManager;
}

- (LifecycleManager *)lifecycleManager
{
    if (_lifecycleManager) {
        return _lifecycleManager;
    }

    _lifecycleManager = [LifecycleManager new];

    return _lifecycleManager;
}

- (UserDefaultsManager *)userDefaults
{
    if (_userDefaults) {
        return _userDefaults;
    }

    _userDefaults = [UserDefaultsManager new];
    [self createUserDefaultsValuesAndRewrite:NO];

    return _userDefaults;
}

#pragma mark -  Public

- (void)restoreDefaultSettings
{
    [self createUserDefaultsValuesAndRewrite:YES];

    // FIXME
    // self.profileManager = nil;

    [self recreateAppearance];
}

- (void)recreateAppearance
{
    self.appearance = nil;
    self.avatars = nil;

    // FIXME
    //    [self.notification resetAppearance];
    // [self.profileManager updateInterface];
}

#pragma mark -  Private

- (void)createUserDefaultsValuesAndRewrite:(BOOL)rewrite
{
    if (rewrite || ! _userDefaults.uShowMessageInLocalNotification) {
        _userDefaults.uShowMessageInLocalNotification = @(YES);
    }

    if (rewrite || ! _userDefaults.uIpv6Enabled) {
        _userDefaults.uIpv6Enabled = @(1);
    }

    if (rewrite || ! _userDefaults.uUDPEnabled) {
        _userDefaults.uUDPEnabled = @(1);
    }

    if (rewrite || ! _userDefaults.uCurrentColorscheme) {
        _userDefaults.uCurrentColorscheme = @(AppearanceManagerColorschemeIce);
    }
}

@end
