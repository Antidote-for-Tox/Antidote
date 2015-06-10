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

NSString *const kProfileManagerUpdateNumberOfUnreadChatsNotification = @"kProfileManagerUpdateNumberOfUnreadChatsNotification";
NSString *const kProfileManagerFriendUpdateNotification = @"kProfileManagerFriendUpdateNotification";
NSString *const kProfileManagerFriendUpdateKey = @"kProfileManagerFriendUpdateKey";
NSString *const kProfileManagerFriendsContainerUpdateNotification = @"kProfileManagerFriendsContainerUpdateNotification";
NSString *const kProfileManagerFriendsContainerUpdateInsertedKey = @"kProfileManagerFriendsContainerUpdateInsertedKey";
NSString *const kProfileManagerFriendsContainerUpdateRemovedKey = @"kProfileManagerFriendsContainerUpdateRemovedKey";
NSString *const kProfileManagerFriendsContainerUpdateUpdatedKey = @"kProfileManagerFriendsContainerUpdateUpdatedKey";

static NSString *const kSaveDirectoryPath = @"saves";
static NSString *const kDefaultProfileName = @"default";
static NSString *const kSaveToxFileName = @"save.tox";

@interface ProfileManager () <OCTArrayDelegate, OCTFriendsContainerDelegate>

@property (strong, nonatomic, readwrite) OCTManager *toxManager;
@property (strong, nonatomic, readwrite) NSArray *allProfiles;

@property (strong, nonatomic, readwrite) OCTArray *allChats;
@property (strong, nonatomic, readwrite) OCTFriendsContainer *friendsContainer;

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

- (NSUInteger)numberOfUnreadChats
{
    __block NSUInteger number = 0;

    [self.allChats enumerateObjectsUsingBlock:^(OCTChat *chat, NSUInteger idx, BOOL *stop) {
        if ([chat hasUnreadMessages]) {
            number++;
        }
    }];

    return number;
}

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

    [self createToxManagerWithDirectoryPath:path name:name];
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
    [self reloadAllProfiles];

    [self createToxManagerWithDirectoryPath:path name:name loadToxSaveFilePath:toxSaveURL.path];
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

        [self createToxManagerWithDirectoryPath:toPath name:toName];
    }

    return YES;
}

- (NSURL *)exportProfileWithName:(NSString *)name
{
    NSString *path = [self.toxManager exportToxSaveFile:nil];

    return [NSURL fileURLWithPath:path];
}

#pragma mark -  OCTArrayDelegate

- (void)OCTArrayWasUpdated:(OCTArray *)array
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kProfileManagerUpdateNumberOfUnreadChatsNotification
                                                        object:nil];
}

#pragma mark -  OCTFriendsContainerDelegate

- (void)friendsContainerUpdate:(OCTFriendsContainer *)container
                   insertedSet:(NSIndexSet *)inserted
                    removedSet:(NSIndexSet *)removed
                    updatedSet:(NSIndexSet *)updated
{
    NSMutableDictionary *userInfo = [NSMutableDictionary new];

    if (inserted) {
        userInfo[kProfileManagerFriendsContainerUpdateInsertedKey] = inserted;
    }
    if (removed) {
        userInfo[kProfileManagerFriendsContainerUpdateRemovedKey] = removed;
    }
    if (updated) {
        userInfo[kProfileManagerFriendsContainerUpdateUpdatedKey] = updated;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kProfileManagerFriendsContainerUpdateNotification
                                                        object:nil
                                                      userInfo:[userInfo copy]];
}

- (void)friendsContainer:(OCTFriendsContainer *)container friendUpdated:(OCTFriend *)friend
{
    NSDictionary *userInfo = @{
        kProfileManagerFriendUpdateKey : friend,
    };

    [[NSNotificationCenter defaultCenter] postNotificationName:kProfileManagerFriendUpdateNotification
                                                        object:nil
                                                      userInfo:userInfo];
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

- (void)createToxManagerWithDirectoryPath:(NSString *)path name:(NSString *)name
{
    [self createToxManagerWithDirectoryPath:path name:name loadToxSaveFilePath:nil];
}

- (void)createToxManagerWithDirectoryPath:(NSString *)path
                                     name:(NSString *)name
                      loadToxSaveFilePath:(NSString *)toxSaveFilePath
{
    OCTManagerConfiguration *configuration = [OCTManagerConfiguration defaultConfiguration];

    configuration.options.IPv6Enabled = [AppContext sharedContext].userDefaults.uIpv6Enabled.boolValue;
    configuration.options.UDPEnabled = [AppContext sharedContext].userDefaults.uUDPEnabled.boolValue;

    NSString *key = [NSString stringWithFormat:@"settingsStorage/%@", name];
    configuration.settingsStorage = [[OCTDefaultSettingsStorage alloc] initWithUserDefaultsKey:key];

    configuration.fileStorage = [[OCTDefaultFileStorage alloc] initWithBaseDirectory:path
                                                                  temporaryDirectory:NSTemporaryDirectory()];

    self.toxManager = [[OCTManager alloc] initWithConfiguration:configuration loadToxSaveFilePath:toxSaveFilePath];

    [self bootstrapToxManager:self.toxManager];

    self.allChats = [self.toxManager.chats allChats];
    self.allChats.delegate = self;

    self.friendsContainer = self.toxManager.friends.friendsContainer;
    self.friendsContainer.delegate = self;
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
