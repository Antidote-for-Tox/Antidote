//
//  ToxManagerAvatars.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 23.10.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxManagerAvatars.h"
#import "ToxManager+Private.h"
#import "ToxManager+PrivateChat.h"
#import "CDUser.h"
#import "ProfileManager.h"
#import "CoreDataManager+User.h"

static NSString *const kUserAvatarFileName = @"user_avatar";

void avatarInfoCallback(Tox *tox, int32_t, uint8_t, uint8_t *, void *);
void avatarDataCallback(Tox *tox, int32_t, uint8_t, uint8_t *, uint8_t *, uint32_t, void *);

@implementation ToxManagerAvatars

#pragma mark -  Public

- (instancetype)initOnToxQueueWithToxManager:(ToxManager *)manager
{
    NSAssert([manager isOnToxManagerQueue], @"Must be on ToxManager queue");

    self = [super init];

    if (! self) {
        return nil;
    }

    DDLogInfo(@"ToxManagerAvatars: registering callbacks");

    tox_callback_avatar_info(manager.tox, avatarInfoCallback, NULL);
    tox_callback_avatar_data(manager.tox, avatarDataCallback, NULL);

    NSString *path = [[ProfileManager sharedInstance] pathInAvatarDirectoryForFileName:kUserAvatarFileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];

        const uint8_t *bytes = [data bytes];

        DDLogInfo(@"ToxManagerAvatars: found avatar, setting it. Length = %lu", (unsigned long)data.length);

        tox_set_avatar(manager.tox, TOX_AVATAR_FORMAT_PNG, bytes, (uint32_t)data.length);
    }

    return self;
}

- (void)qUpdateAvatar:(UIImage *)image
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManagerAvatars: update avatar with image %@", image);

    NSString *path = [[ProfileManager sharedInstance] pathInAvatarDirectoryForFileName:kUserAvatarFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:path]) {
        DDLogInfo(@"ToxManagerAvatars: old avatar exists, removing it");

        [fileManager removeItemAtPath:path error:nil];
    }

    if (image) {
        DDLogInfo(@"ToxManagerAvatars: setting new avatar...");

        NSData *data = [self pngDataFromImage:image];

        [fileManager createDirectoryAtPath:[path stringByDeletingLastPathComponent]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];

        [data writeToFile:path atomically:NO];

        const uint8_t *bytes = [data bytes];

        tox_set_avatar([ToxManager sharedInstance].tox, TOX_AVATAR_FORMAT_PNG, bytes, (uint32_t)data.length);

        DDLogInfo(@"ToxManagerAvatars: setting new avatar... done");
    }
    else {
        DDLogInfo(@"ToxManagerAvatars: unsetting avatar");

        tox_unset_avatar([ToxManager sharedInstance].tox);
    }
}

- (BOOL)synchronizedUserHasAvatar
{
    NSString *path = [[ProfileManager sharedInstance] pathInAvatarDirectoryForFileName:kUserAvatarFileName];

    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (UIImage *)synchronizedUserAvatar
{
    NSString *path = [[ProfileManager sharedInstance] pathInAvatarDirectoryForFileName:kUserAvatarFileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return [UIImage imageWithContentsOfFile:path];
    }

    return nil;
}

#pragma mark -  Private

- (void)qRemoveAvatarForFriend:(ToxFriend *)theFriend
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    NSFileManager *fileManager = [NSFileManager defaultManager];

    [[ToxManager sharedInstance].friendsContainer private_updateFriendWithId:theFriend.id
                                                                 updateBlock:^(ToxFriend *friend)
    {
        NSString *path = [[ProfileManager sharedInstance] pathInAvatarDirectoryForFileName:friend.clientId];

        if ([fileManager fileExistsAtPath:path]) {
            DDLogInfo(@"ToxManagerAvatars: removing avatar for friend %d", friend.id);

            [fileManager removeItemAtPath:path error:nil];
        }

        [[ToxManager sharedInstance] qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
            [CoreDataManager editCDObjectWithBlock:^{
                user.avatarHash = nil;
            } completionQueue:nil completionBlock:nil];
        }];
    }];
}

- (void)qIncomingAvatarInfoForFriend:(ToxFriend *)friend hash:(NSData *)hash
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    [[ToxManager sharedInstance] qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
        if (user.avatarHash && [user.avatarHash isEqualToData:hash]) {
            DDLogInfo(@"ToxManagerAvatars: already have this avatar");
            return;
        }

        DDLogInfo(@"ToxManagerAvatars: requesting avatar data for friend %d", friend.id);
        tox_request_avatar_data([ToxManager sharedInstance].tox, friend.id);
    }];
}

- (void)qIncomingAvatarData:(NSData *)data hash:(NSData *)hash forFriend:(ToxFriend *)theFriend
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    NSFileManager *fileManager = [NSFileManager defaultManager];

    [[ToxManager sharedInstance].friendsContainer private_updateFriendWithId:theFriend.id
                                                                 updateBlock:^(ToxFriend *friend)
    {
        NSString *path = [[ProfileManager sharedInstance] pathInAvatarDirectoryForFileName:friend.clientId];

        if ([fileManager fileExistsAtPath:path]) {
            DDLogInfo(@"ToxManagerAvatars: old avatar exists, removing it");

            [fileManager removeItemAtPath:path error:nil];
        }

        [fileManager createDirectoryAtPath:[path stringByDeletingLastPathComponent]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];

        [data writeToFile:path atomically:NO];

        [[ToxManager sharedInstance] qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
            [CoreDataManager editCDObjectWithBlock:^{
                user.avatarHash = hash;
            } completionQueue:nil completionBlock:nil];
        }];
    }];
}

- (NSData *)pngDataFromImage:(UIImage *)image
{
    CGSize imageSize = image.size;

    DDLogInfo(@"ToxManagerAvatars: image size is %@", NSStringFromCGSize(imageSize));

    // Maximum png size will be (4 * width * height)
    // * 1.5 to get as big avatar size as possible
    while (4 * imageSize.width * imageSize.height > TOX_AVATAR_MAX_DATA_LENGTH * 1.5) {
        imageSize.width *= 0.9;
        imageSize.height *= 0.9;
    }

    imageSize.width = (int)imageSize.width;
    imageSize.height = (int)imageSize.height;
    DDLogInfo(@"ToxManagerAvatars: image size after resizing %@", NSStringFromCGSize(imageSize));

    NSData *data = nil;

    do {
        DDLogInfo(@"ToxManagerAvatars: setting new avatar... avatar is too big, resizing");

        UIGraphicsBeginImageContext(imageSize);
        [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        data = UIImagePNGRepresentation(image);

        imageSize.width *= 0.9;
        imageSize.height *= 0.9;
    } while (data.length > TOX_AVATAR_MAX_DATA_LENGTH);

    return data;
}

@end

#pragma mark -  C functions

void avatarInfoCallback(Tox *tox, int32_t friendnumber, uint8_t format, uint8_t *hash, void *userdata)
{
    DDLogCVerbose(@"ToxManagerAvatars: avatarInfoCallback with friendnumber %d format %d hash %s",
            friendnumber, format, hash);

    ToxFriend *friend = [[ToxManager sharedInstance].friendsContainer friendWithId:friendnumber];
    NSData *data = [NSData dataWithBytes:hash length:TOX_HASH_LENGTH];

    dispatch_async([ToxManager sharedInstance].queue, ^{
        if (format == TOX_AVATAR_FORMAT_NONE) {
            [[ToxManager sharedInstance].managerAvatars qRemoveAvatarForFriend:friend];
        }
        else if (format == TOX_AVATAR_FORMAT_PNG) {
            [[ToxManager sharedInstance].managerAvatars qIncomingAvatarInfoForFriend:friend hash:data];
        }
    });
}

void avatarDataCallback(Tox *tox,
        int32_t friendnumber,
        uint8_t format,
        uint8_t *hash,
        uint8_t *data,
        uint32_t datalen,
        void *userdata)
{
    DDLogCVerbose(@"ToxManagerAvatars: avatarData with friendnumber %d format %d hash %s",
            friendnumber, format, hash);

    ToxFriend *friend = [[ToxManager sharedInstance].friendsContainer friendWithId:friendnumber];

    NSData *nsData = [NSData dataWithBytes:data length:datalen];
    NSData *nsHash = [NSData dataWithBytes:hash length:TOX_HASH_LENGTH];

    if (format == TOX_AVATAR_FORMAT_PNG) {
        dispatch_async([ToxManager sharedInstance].queue, ^{
            [[ToxManager sharedInstance].managerAvatars qIncomingAvatarData:nsData hash:nsHash forFriend:friend];
        });
    }
}

