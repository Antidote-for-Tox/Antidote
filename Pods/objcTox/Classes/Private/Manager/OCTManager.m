//
//  OCTManager.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 06.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <objc/runtime.h>

#import "OCTManager.h"
#import "OCTTox.h"
#import "OCTSubmanagerUser+Private.h"
#import "OCTSubmanagerFriends+Private.h"
#import "OCTSubmanagerChats+Private.h"
#import "OCTSubmanagerAvatars+Private.h"
#import "OCTDBManager.h"

@interface OCTManager() <OCTToxDelegate, OCTSubmanagerDataSource>

@property (strong, nonatomic, readonly) OCTTox *tox;
@property (copy, nonatomic, readonly) OCTManagerConfiguration *configuration;

@property (strong, nonatomic, readwrite) OCTSubmanagerUser *user;
@property (strong, nonatomic, readwrite) OCTSubmanagerFriends *friends;
@property (strong, nonatomic, readwrite) OCTSubmanagerChats *chats;
@property (strong, nonatomic, readwrite) OCTSubmanagerAvatars *avatars;

@property (strong, nonatomic) OCTDBManager *dbManager;

@end

@implementation OCTManager

#pragma mark -  Lifecycle

- (instancetype)initWithConfiguration:(OCTManagerConfiguration *)configuration
{
    self = [super init];

    if (! self) {
        return nil;
    }

    [self validateConfiguration:configuration];

    _configuration = [configuration copy];

    NSData *savedData = nil;
    NSString *savedDataPath = configuration.fileStorage.pathForToxSaveFile;

    if ([[NSFileManager defaultManager] fileExistsAtPath:savedDataPath]) {
        savedData = [NSData dataWithContentsOfFile:savedDataPath];
    }

    _tox = [[OCTTox alloc] initWithOptions:configuration.options savedData:savedData error:nil];
    _tox.delegate = self;

    _dbManager = [[OCTDBManager alloc] initWithDatabasePath:configuration.fileStorage.pathForDatabase];

    OCTSubmanagerUser *user = [OCTSubmanagerUser new];
    user.dataSource = self;
    _user = user;

    OCTSubmanagerFriends *friends = [OCTSubmanagerFriends new];
    friends.dataSource = self;
    [friends configure];
    _friends = friends;

    OCTSubmanagerChats *chats = [OCTSubmanagerChats new];
    chats.dataSource = self;
    _chats = chats;

    OCTSubmanagerAvatars *avatars = [OCTSubmanagerAvatars new];
    avatars.dataSource = self;
    _avatars = avatars;

    return self;
}

#pragma mark -  Public

- (BOOL)bootstrapFromHost:(NSString *)host port:(OCTToxPort)port publicKey:(NSString *)publicKey error:(NSError **)error
{
    return [self.tox bootstrapFromHost:host port:port publicKey:publicKey error:error];
}

- (BOOL)addTCPRelayWithHost:(NSString *)host port:(OCTToxPort)port publicKey:(NSString *)publicKey error:(NSError **)error
{
    return [self.tox addTCPRelayWithHost:host port:port publicKey:publicKey error:error];
}

#pragma mark -  OCTSubmanagerDataSource

- (OCTTox *)managerGetTox
{
    return self.tox;
}

- (BOOL)managerSaveTox:(NSError **)error
{
    return [self saveTox:error];
}

- (OCTDBManager *)managerGetDBManager
{
    return self.dbManager;
}

- (id<OCTSettingsStorageProtocol>)managerGetSettingsStorage
{
    return self.configuration.settingsStorage;
}

- (id<OCTFileStorageProtocol>)managerGetFileStorage
{
    return self.configuration.fileStorage;
}

#pragma mark -  Private

- (void)validateConfiguration:(OCTManagerConfiguration *)configuration
{
    NSParameterAssert(configuration.settingsStorage);

    NSParameterAssert(configuration.fileStorage);
    NSParameterAssert(configuration.fileStorage.pathForDownloadedFilesDirectory);
    NSParameterAssert(configuration.fileStorage.pathForUploadedFilesDirectory);
    NSParameterAssert(configuration.fileStorage.pathForTemporaryFilesDirectory);
    NSParameterAssert(configuration.fileStorage.pathForAvatarsDirectory);

    NSParameterAssert(configuration.options);
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    struct objc_method_description description = protocol_getMethodDescription(@protocol(OCTToxDelegate), aSelector, NO, YES);

    if (description.name == NULL) {
        // We forward methods only from OCTToxDelegate protocol.
        return nil;
    }

    NSArray *submanagers = @[
        self.user,
        self.friends,
        self.chats,
        self.avatars,
    ];

    for (id delegate in submanagers) {
        if ([delegate respondsToSelector:aSelector]) {
            return delegate;
        }
    }

    return nil;
}

- (BOOL)saveTox:(NSError **)error
{
    NSString *savedDataPath = self.configuration.fileStorage.pathForToxSaveFile;

    NSData *data = [self.tox save];

    return [data writeToFile:savedDataPath options:0 error:error];
}

@end
