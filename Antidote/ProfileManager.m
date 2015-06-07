//
//  ProfileManager.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 07.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ProfileManager.h"
#import "NSArray+BlocksKit.h"
#import "UserDefaultsManager.h"
#import "OCTManager.h"
#import "OCTDefaultSettingsStorage.h"
#import "OCTDefaultFileStorage.h"

static NSString *const kSaveDirectoryPath = @"saves";
static NSString *const kDefaultProfileName = @"default";
static NSString *const kSaveToxFileName = @"save.tox";

@interface ProfileManager()

@property (strong, nonatomic, readwrite) OCTManager *toxManager;
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

    [self createDirectoryAtPathIfNotExist:[self saveDirectoryPath]];
    [self reloadAllProfiles];

    if (self.allProfiles.count) {
        NSString *name = [AppContext sharedContext].userDefaults.uCurrentProfileName;
        [self switchToProfileWithName:name];
    }
    else {
        [self switchToProfileWithName:kDefaultProfileName];
    }

    return self;
}

#pragma mark -  Properties

- (NSString *)currentProfileName
{
    return [AppContext sharedContext].userDefaults.uCurrentProfileName;
}

#pragma mark -  Methods

- (void)switchToProfileWithName:(NSString *)name
{
    NSAssert(name.length > 0, @"name cannot be empty");

    [AppContext sharedContext].userDefaults.uCurrentProfileName = name;

    NSString *path = [[self saveDirectoryPath] stringByAppendingPathComponent:name];

    [self createDirectoryAtPathIfNotExist:path];
    [self reloadAllProfiles];

    self.toxManager = [self createToxManagerWithDirectoryPath:path name:name];
    [self bootstrapToxManager:self.toxManager];
}

- (void)createProfileWithToxSave:(NSURL *)toxSaveURL name:(NSString *)name
{
    NSParameterAssert(toxSaveURL);
    NSAssert(name.length > 0, @"name cannot be empty");

    if ([self.allProfiles containsObject:name]) {
        name = [self createUniqueNameFromName:name];
    }

    NSString *path = [[self saveDirectoryPath] stringByAppendingPathComponent:name];
    [self createDirectoryAtPathIfNotExist:path];

    path = [path stringByAppendingPathComponent:kSaveToxFileName];

    // FIXME this is temporary solution, we need objcTox API for that
    [[NSFileManager defaultManager] copyItemAtPath:toxSaveURL.path toPath:path error:nil];

    [self switchToProfileWithName:name];
}

- (void)deleteProfileWithName:(NSString *)name
{
    NSAssert(name.length > 0, @"name cannot be empty");

    BOOL isCurrent = [[self currentProfileName] isEqualToString:name];

    if (isCurrent) {
        self.toxManager = nil;
    }

    NSString *path = [[self saveDirectoryPath] stringByAppendingPathComponent:name];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];

    [self reloadAllProfiles];

    if (isCurrent) {
        NSString *nameToSwitch = [self.allProfiles firstObject] ?: kDefaultProfileName;
        [self switchToProfileWithName:nameToSwitch];
    }
}

- (BOOL)renameProfileWithName:(NSString *)name toName:(NSString *)toName
{
    NSAssert(name.length > 0, @"name cannot be empty");
    NSAssert(toName.length > 0, @"toName cannot be empty");

    if ([self.allProfiles containsObject:toName]) {
        return NO;
    }

    BOOL isCurrent = [[self currentProfileName] isEqualToString:name];

    if (isCurrent) {
        self.toxManager = nil;
    }

    NSString *fromPath = [[self saveDirectoryPath] stringByAppendingPathComponent:name];
    NSString *toPath = [[self saveDirectoryPath] stringByAppendingPathComponent:toName];

    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];

    [self reloadAllProfiles];

    if (isCurrent) {
        [AppContext sharedContext].userDefaults.uCurrentProfileName = toName;

        self.toxManager = [self createToxManagerWithDirectoryPath:toPath name:toName];
        [self bootstrapToxManager:self.toxManager];
    }

    return YES;
}

- (NSURL *)exportProfileWithName:(NSString *)name
{
    // FIXME this is temporary solution, we need objcTox API for that

    NSString *path = [[self saveDirectoryPath] stringByAppendingPathComponent:name];
    path = [path stringByAppendingPathComponent:kSaveToxFileName];

    return [NSURL fileURLWithPath:path];
}

#pragma mark -  Private

- (NSString *)saveDirectoryPath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [path stringByAppendingPathComponent:kSaveDirectoryPath];
}

- (void)createDirectoryAtPathIfNotExist:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    BOOL isDirectory;
    BOOL exists = [fileManager fileExistsAtPath:path isDirectory:&isDirectory];

    if (exists && ! isDirectory) {
        [fileManager removeItemAtPath:path error:nil];
        exists = NO;
    }

    if (! exists) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
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

- (OCTManager *)createToxManagerWithDirectoryPath:(NSString *)path name:(NSString *)name
{
    OCTManagerConfiguration *configuration = [OCTManagerConfiguration defaultConfiguration];

    configuration.options.IPv6Enabled = [AppContext sharedContext].userDefaults.uIpv6Enabled.boolValue;
    configuration.options.UDPEnabled = [AppContext sharedContext].userDefaults.uUDPEnabled.boolValue;

    NSString *key = [NSString stringWithFormat:@"settingsStorage/%@", name];
    configuration.settingsStorage = [[OCTDefaultSettingsStorage alloc] initWithUserDefaultsKey:key];

    configuration.fileStorage = [[OCTDefaultFileStorage alloc] initWithBaseDirectory:path
                                                                  temporaryDirectory:NSTemporaryDirectory()];

    return [[OCTManager alloc] initWithConfiguration:configuration];
}

- (void)bootstrapToxManager:(OCTManager *)manager
{
    [manager bootstrapFromHost:@"192.254.75.102"
                          port:33445
                     publicKey:@"951C88B7E75C867418ACDB5D273821372BB5BD652740BCDF623A4FA293E75D2F"
                         error:nil];

    [manager bootstrapFromHost:@"178.62.125.224"
                          port:33445
                     publicKey:@"10B20C49ACBD968D7C80F2E8438F92EA51F189F4E70CFBBB2C2C8C799E97F03E"
                         error:nil];

    [manager bootstrapFromHost:@"192.210.149.121"
                          port:33445
                     publicKey:@"F404ABAA1C99A9D37D61AB54898F56793E1DEF8BD46B1038B9D822E8460FAB67"
                         error:nil];
}

- (NSString *)createUniqueNameFromName:(NSString *)name
{
    NSString *result = name;
    NSUInteger count = 0;

    while ([self.allProfiles containsObject:result]) {

        result = [name stringByAppendingFormat:@"-%lu", count];
    }

    return result;
}

@end
