//
//  ProfileManager.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 17.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ProfileManager.h"
#import "CoreDataManager+Profile.h"
#import "UserInfoManager.h"
#import "ToxManager.h"
#import "AvatarManager.h"

static NSString *const kToxSaveName = @"tox_save";

@interface ProfileManager()

@property (strong, nonatomic, readwrite) CDProfile *currentProfile;

@end

@implementation ProfileManager

#pragma mark -  Lifecycle

- (id)init
{
    return nil;
}

- (id)initPrivate
{
    if (self = [super init]) {

    }

    return self;
}

+ (instancetype)sharedInstance
{
    static ProfileManager *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[ProfileManager alloc] initPrivate];
    });

    return instance;
}

#pragma mark -  Public

- (void)configureCurrentProfileAndLoadTox
{
    NSString *fileName = [UserInfoManager sharedInstance].uCurrentProfileFileName;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileName == %@", fileName];

    self.currentProfile = [CoreDataManager syncProfileWithPredicate:predicate];

    if (self.currentProfile) {
        [self loadToxManagerForCurrentProfile];
        return;
    }

    self.currentProfile = [CoreDataManager syncAddProfileWithConfigBlock:^(CDProfile *profile) {
        // default name
        profile.name = NSLocalizedString(@"Main", @"Main profile name");
        profile.fileName = [[NSUUID UUID] UUIDString];
    }];

    [UserInfoManager sharedInstance].uCurrentProfileFileName = self.currentProfile.fileName;

    [self loadToxManagerForCurrentProfile];
}

- (NSData *)toxDataForCurrentProfile
{
    NSString *path = [self toxDataPathForProfile:self.currentProfile];

    return [NSData dataWithContentsOfFile:path];
}

- (void)saveToxDataForCurrentProfile:(NSData *)data
{
    NSString *path = [self toxDataPathForProfile:self.currentProfile];

    [data writeToFile:path atomically:NO];
}

- (void)addNewProfileWithName:(NSString *)name
{
    [CoreDataManager addProfileWithConfigBlock:^(CDProfile *profile) {
        profile.name = name;
        profile.fileName = [[NSUUID UUID] UUIDString];

    } completionQueue:nil completionBlock:nil];
}

- (void)addNewProfileWithName:(NSString *)name fromURL:(NSURL *)url removeAfterAdding:(BOOL)removeAfterAdding
{
    [CoreDataManager addProfileWithConfigBlock:^(CDProfile *profile) {
        profile.name = name;
        profile.fileName = [[NSUUID UUID] UUIDString];

    } completionQueue:dispatch_get_main_queue() completionBlock:^(CDProfile *profile) {
        NSString *path = [self profileDirectoryWithFileName:profile.fileName];

        NSFileManager *fileManager = [NSFileManager defaultManager];

        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];

        NSURL *newURL = [[NSURL fileURLWithPath:path] URLByAppendingPathComponent:kToxSaveName];

        if (removeAfterAdding) {
            [fileManager moveItemAtURL:url toURL:newURL error:nil];
        }
        else {
            [fileManager copyItemAtURL:url toURL:newURL error:nil];
        }
    }];
}

- (void)switchToProfile:(CDProfile *)profile
{
    [[ToxManager sharedInstance] killSharedInstance];
    [AvatarManager clearCache];

    [UserInfoManager sharedInstance].uCurrentProfileFileName = profile.fileName;
    self.currentProfile = profile;

    [self loadToxManagerForCurrentProfile];
}

- (void)renameProfile:(CDProfile *)profile to:(NSString *)name
{
    [CoreDataManager editCDObjectWithBlock:^{
        profile.name = name;
    } completionQueue:nil completionBlock:nil];
}

- (void)deleteProfile:(CDProfile *)profile
{
    if ([profile.fileName isEqual:[UserInfoManager sharedInstance].uCurrentProfileFileName]) {
        return;
    }

    NSString *path = [self profileDirectoryWithFileName:profile.fileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }

    [CoreDataManager removeProfileWithAllRelatedCDObjects:profile completionQueue:nil completionBlock:nil];
}

- (NSURL *)toxDataURLForProfile:(CDProfile *)profile
{
    NSString *path = [self toxDataPathForProfile:profile];

    return [NSURL fileURLWithPath:path isDirectory:NO];
}

- (NSString *)pathInFilesForCurrentProfileFromFileName:(NSString *)fileName temporary:(BOOL)temporary
{
    NSString *path = [self fileDirectoryPathForCurrentProfileIsTemporary:temporary];

    return [path stringByAppendingPathComponent:fileName];
}

- (NSString *)fileDirectoryPathForCurrentProfileIsTemporary:(BOOL)temporary
{
    NSString *path = nil;

    if (temporary) {
        path = NSTemporaryDirectory();
    }
    else {
        path = [self profileDirectoryWithFileName:self.currentProfile.fileName];
    }

    return [path stringByAppendingPathComponent:@"Files"];
}

- (NSString *)pathInAvatarDirectoryForFileName:(NSString *)avatarHash
{
    NSString *path = [self profileDirectoryWithFileName:self.currentProfile.fileName];

    return [[path stringByAppendingPathComponent:@"Avatars"] stringByAppendingPathComponent:avatarHash];
}

#pragma mark -  Private

- (void)loadToxManagerForCurrentProfile
{
    [[ToxManager sharedInstance] configureSelfAndBootstrapWithNodes:@[
        [ToxNode nodeWithAddress:@"192.254.75.102"
                            port:33445
                       publicKey:@"951C88B7E75C867418ACDB5D273821372BB5BD652740BCDF623A4FA293E75D2F"],

        [ToxNode nodeWithAddress:@"178.62.125.224"
                            port:33445
                       publicKey:@"10B20C49ACBD968D7C80F2E8438F92EA51F189F4E70CFBBB2C2C8C799E97F03E"],

        [ToxNode nodeWithAddress:@"23.226.230.47"
                            port:33445
                       publicKey:@"A09162D68618E742FFBCA1C2C70385E6679604B2D80EA6E84AD0996A1AC8A074"],

        [ToxNode nodeWithAddress:@"178.62.250.138"
                            port:33445
                       publicKey:@"788236D34978D1D5BD822F0A5BEBD2C53C64CC31CD3149350EE27D4D9A2F9B6B"],
    ]];
}

- (NSString *)directoryWithToxSaves
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

    return [path stringByAppendingPathComponent:@"ToxSaves"];
}

- (NSString *)profileDirectoryWithFileName:(NSString *)fileName
{
    NSString *path = [self directoryWithToxSaves];
    return [path stringByAppendingPathComponent:fileName];
}

- (NSString *)toxDataPathForProfile:(CDProfile *)profile
{
    NSString *path = [self profileDirectoryWithFileName:profile.fileName];

    path = [path stringByAppendingPathComponent:kToxSaveName];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (! [fileManager fileExistsAtPath:path]) {
         [fileManager createDirectoryAtPath:[path stringByDeletingLastPathComponent]
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:nil];

         [fileManager createFileAtPath:path contents:nil attributes:nil];
    }

    return path;
}

@end
