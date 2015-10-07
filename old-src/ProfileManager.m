//
//  ProfileManager.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 07.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <objcTox/OCTDefaultFileStorage.h>
#import <objcTox/OCTManagerConfiguration.h>

#import "ProfileManager.h"
#import "NSArray+BlocksKit.h"
#import "UserDefaultsManager.h"

static NSString *const kSaveDirectoryPath = @"saves";

@interface ProfileManager ()

@property (strong, nonatomic, readwrite) NSArray *allProfiles;

@end

@implementation ProfileManager

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    [self reloadAllProfiles];

    return self;
}

#pragma mark -  Methods

- (BOOL)createProfileWithName:(NSString *)name error:(NSError **)error
{
    NSAssert(name.length > 0, @"name cannot be empty");

    NSString *path = [[self saveDirectoryPath] stringByAppendingPathComponent:name];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (! [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error]) {
        return NO;
    }

    [self reloadAllProfiles];

    return YES;
}

- (BOOL)deleteProfileWithName:(NSString *)name error:(NSError **)error
{
    NSAssert(name.length > 0, @"name cannot be empty");

    NSString *path = [[self saveDirectoryPath] stringByAppendingPathComponent:name];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (! [fileManager removeItemAtPath:path error:error]) {
        return NO;
    }

    [self reloadAllProfiles];

    return YES;
}

- (BOOL)renameProfileWithName:(NSString *)name toName:(NSString *)toName error:(NSError **)error
{
    NSAssert(name.length > 0, @"name cannot be empty");
    NSAssert(toName.length > 0, @"toName cannot be empty");

    NSString *fromPath = [[self saveDirectoryPath] stringByAppendingPathComponent:name];
    NSString *toPath = [[self saveDirectoryPath] stringByAppendingPathComponent:toName];

    if (! [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:error]) {
        return NO;
    }

    [self reloadAllProfiles];

    return YES;
}

- (OCTManagerConfiguration *)configurationForProfileWithName:(NSString *)name passphrase:(NSString *)passphrase
{
    NSString *path = [[self saveDirectoryPath] stringByAppendingPathComponent:name];

    BOOL isDirectory = NO;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];

    if (! exists || ! isDirectory) {
        return nil;
    }

    OCTManagerConfiguration *configuration = [OCTManagerConfiguration defaultConfiguration];
    configuration.passphrase = passphrase;

    configuration.options.IPv6Enabled = [AppContext sharedContext].userDefaults.uIpv6Enabled.boolValue;
    configuration.options.UDPEnabled = [AppContext sharedContext].userDefaults.uUDPEnabled.boolValue;

    configuration.fileStorage = [[OCTDefaultFileStorage alloc] initWithBaseDirectory:path
                                                                  temporaryDirectory:NSTemporaryDirectory()];

    return configuration;
}

#pragma mark -  Private

- (NSString *)saveDirectoryPath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [path stringByAppendingPathComponent:kSaveDirectoryPath];
}

- (void)reloadAllProfiles
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *savePath = [self saveDirectoryPath];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:savePath error:nil];

    self.allProfiles = [contents bk_select:^BOOL (NSString *name) {
        NSString *path = [savePath stringByAppendingPathComponent:name];
        BOOL isDirectory;

        [fileManager fileExistsAtPath:path isDirectory:&isDirectory];

        return isDirectory;
    }];
}

@end
