//
//  ToxManager+PrivateAvatars.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxManager+PrivateAvatars.h"
#import "ToxManager+Private.h"
#import "ToxManager+PrivateChat.h"
#import "CDUser.h"
#import "ProfileManager.h"
#import "CoreDataManager+User.h"

static NSString *const kUserAvatarFileName = @"user_avatar";

void avatarInfoCallback(Tox *tox, int32_t, uint8_t, uint8_t *, void *);
void avatarDataCallback(Tox *tox, int32_t, uint8_t, uint8_t *, uint8_t *, uint32_t, void *);

@implementation ToxManager (PrivateAvatars)

#pragma mark -  Public

- (void)qRegisterAvatarCallbacksAndSetup
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager+PrivateAvatars: registering callbacks");

    tox_callback_avatar_info(self.tox, avatarInfoCallback, NULL);
    tox_callback_avatar_data(self.tox, avatarDataCallback, NULL);

    NSString *path = [[ProfileManager sharedInstance] pathInAvatarDirectoryForFileName:kUserAvatarFileName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];

        const uint8_t *bytes = [data bytes];

        DDLogInfo(@"ToxManager+PrivateAvatars: found avatar, setting it. Length = %lu", data.length);

        tox_set_avatar(self.tox, TOX_AVATAR_FORMAT_PNG, bytes, (uint32_t)data.length);
    }
}

- (void)qUpdateAvatar:(UIImage *)image
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager+PrivateAvatars: update avatar with image %@", image);

    NSString *path = [[ProfileManager sharedInstance] pathInAvatarDirectoryForFileName:kUserAvatarFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:path]) {
        DDLogInfo(@"ToxManager+PrivateAvatars: old avatar exists, removing it");

        [fileManager removeItemAtPath:path error:nil];
    }

    if (image) {
        DDLogInfo(@"ToxManager+PrivateAvatars: setting new avatar...");

        NSData *data = [self pngDataFromImage:image];

        [fileManager createDirectoryAtPath:[path stringByDeletingLastPathComponent]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];

        [data writeToFile:path atomically:NO];

        const uint8_t *bytes = [data bytes];

        tox_set_avatar(self.tox, TOX_AVATAR_FORMAT_PNG, bytes, (uint32_t)data.length);

        DDLogInfo(@"ToxManager+PrivateAvatars: setting new avatar... done");
    }
    else {
        DDLogInfo(@"ToxManager+PrivateAvatars: unsetting avatar");

        tox_unset_avatar(self.tox);
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
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    NSFileManager *fileManager = [NSFileManager defaultManager];
    __weak ToxManager *weakSelf = self;

    [self.friendsContainer private_updateFriendWithId:theFriend.id updateBlock:^(ToxFriend *friend) {
        NSString *path = [[ProfileManager sharedInstance] pathInAvatarDirectoryForFileName:friend.clientId];

        if ([fileManager fileExistsAtPath:path]) {
            DDLogInfo(@"ToxManager+PrivateAvatars: removing avatar for friend %d", friend.id);

            [fileManager removeItemAtPath:path error:nil];
        }

        [weakSelf qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
            [CoreDataManager editCDObjectWithBlock:^{
                user.avatarHash = nil;
            } completionQueue:nil completionBlock:nil];
        }];
    }];
}

- (void)qIncomingAvatarInfoForFriend:(ToxFriend *)friend hash:(NSData *)hash
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    __weak ToxManager *weakSelf = self;

    [self qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
        if (user.avatarHash && [user.avatarHash isEqualToData:hash]) {
            DDLogInfo(@"ToxManager+PrivateAvatars: already have this avatar");
            return;
        }

        DDLogInfo(@"ToxManager+PrivateAvatars: requesting avatar data for friend %d", friend.id);
        tox_request_avatar_data(weakSelf.tox, friend.id);
    }];
}

- (void)qIncomingAvatarData:(NSData *)data hash:(NSData *)hash forFriend:(ToxFriend *)theFriend
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    NSFileManager *fileManager = [NSFileManager defaultManager];
    __weak ToxManager *weakSelf = self;

    [self.friendsContainer private_updateFriendWithId:theFriend.id updateBlock:^(ToxFriend *friend) {
        NSString *path = [[ProfileManager sharedInstance] pathInAvatarDirectoryForFileName:friend.clientId];

        if ([fileManager fileExistsAtPath:path]) {
            DDLogInfo(@"ToxManager+PrivateAvatars: old avatar exists, removing it");

            [fileManager removeItemAtPath:path error:nil];
        }

        [fileManager createDirectoryAtPath:[path stringByDeletingLastPathComponent]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];

        [data writeToFile:path atomically:NO];

        [weakSelf qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
            [CoreDataManager editCDObjectWithBlock:^{
                user.avatarHash = hash;
            } completionQueue:nil completionBlock:nil];
        }];
    }];
}

- (NSData *)pngDataFromImage:(UIImage *)image
{
    CGSize imageSize = image.size;
    BOOL shouldResize = NO;

    DDLogInfo(@"ToxManager+PrivateAvatars: image size is %@", NSStringFromCGSize(imageSize));

    // Maximum png size will be (4 * width * height)
    while (4 * imageSize.width * imageSize.height > TOX_AVATAR_MAX_DATA_LENGTH) {
        imageSize.width *= 0.9;
        imageSize.height *= 0.9;

        shouldResize = YES;
    }

    imageSize.width = (int)imageSize.width;
    imageSize.height = (int)imageSize.height;
    DDLogInfo(@"ToxManager+PrivateAvatars: image size after resizing %@", NSStringFromCGSize(imageSize));

    if (! shouldResize) {
        return UIImagePNGRepresentation(image);
    }

    NSData *data = nil;

    do {
        DDLogInfo(@"ToxManager+PrivateAvatars: setting new avatar... avatar is too big, resizing");

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
    DDLogCVerbose(@"ToxManager+PrivateAvatars: avatarInfoCallback with friendnumber %d format %d hash %s",
            friendnumber, format, hash);

    ToxFriend *friend = [[ToxManager sharedInstance].friendsContainer friendWithId:friendnumber];
    NSData *data = [NSData dataWithBytes:hash length:TOX_HASH_LENGTH];

    dispatch_async([ToxManager sharedInstance].queue, ^{
        if (format == TOX_AVATAR_FORMAT_NONE) {
            [[ToxManager sharedInstance] qRemoveAvatarForFriend:friend];
        }
        else if (format == TOX_AVATAR_FORMAT_PNG) {
            [[ToxManager sharedInstance] qIncomingAvatarInfoForFriend:friend hash:data];
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
    DDLogCVerbose(@"ToxManager+PrivateAvatars: avatarData with friendnumber %d format %d hash %s",
            friendnumber, format, hash);

    ToxFriend *friend = [[ToxManager sharedInstance].friendsContainer friendWithId:friendnumber];

    NSData *nsData = [NSData dataWithBytes:data length:datalen];
    NSData *nsHash = [NSData dataWithBytes:hash length:TOX_HASH_LENGTH];

    if (format == TOX_AVATAR_FORMAT_PNG) {
        dispatch_async([ToxManager sharedInstance].queue, ^{
            [[ToxManager sharedInstance] qIncomingAvatarData:nsData hash:nsHash forFriend:friend];
        });
    }
}
