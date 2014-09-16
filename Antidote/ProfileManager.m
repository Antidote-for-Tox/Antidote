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
        profile.name = @"tox_save";
        profile.fileName = [[NSUUID UUID] UUIDString];
    }];

    [UserInfoManager sharedInstance].uCurrentProfileFileName = self.currentProfile.fileName;

    [self loadToxManagerForCurrentProfile];
}

- (NSData *)toxDataForCurrentProfile
{
    NSString *path = [self toxDataPathForCurrentProfile];

    return [NSData dataWithContentsOfFile:path];
}

- (void)saveToxDataForCurrentProfile:(NSData *)data
{
    NSString *path = [self toxDataPathForCurrentProfile];

    [data writeToFile:path atomically:NO];
}

- (void)addNewProfileWithName:(NSString *)name
{
    [CoreDataManager addProfileWithConfigBlock:^(CDProfile *profile) {
        profile.name = name;
        profile.fileName = [[NSUUID UUID] UUIDString];

    } completionQueue:dispatch_get_main_queue() completionBlock:nil];
}

- (void)switchToProfile:(CDProfile *)profile
{
    [[ToxManager sharedInstance] killSharedInstance];

    [UserInfoManager sharedInstance].uCurrentProfileFileName = profile.fileName;
    self.currentProfile = profile;

    [self loadToxManagerForCurrentProfile];
}

#pragma mark -  Private

- (void)loadToxManagerForCurrentProfile
{
    [[ToxManager sharedInstance] bootstrapWithNodes:@[
        [ToxNode nodeWithAddress:@"192.254.75.98"
                            port:33445
                       publicKey:@"951C88B7E75C867418ACDB5D273821372BB5BD652740BCDF623A4FA293E75D2F"],

        [ToxNode nodeWithAddress:@"107.161.17.51"
                            port:33445
                       publicKey:@"7BE3951B97CA4B9ECDDA768E8C52BA19E9E2690AB584787BF4C90E04DBB75111"],

        [ToxNode nodeWithAddress:@"23.226.230.47"
                            port:33445
                       publicKey:@"A09162D68618E742FFBCA1C2C70385E6679604B2D80EA6E84AD0996A1AC8A074"],

        [ToxNode nodeWithAddress:@"37.59.102.176"
                            port:33445
                       publicKey:@"B98A2CEAA6C6A2FADC2C3632D284318B60FE5375CCB41EFA081AB67F500C1B0B"],
    ]];
}

- (NSString *)directoryWithToxSaves
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

    return [path stringByAppendingPathComponent:@"ToxSaves"];
}

- (NSString *)toxDataPathForCurrentProfile
{
    NSString *path = [self directoryWithToxSaves];
    path = [path stringByAppendingPathComponent:self.currentProfile.fileName];

    path = [path stringByAppendingPathComponent:@"tox_save"];

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
