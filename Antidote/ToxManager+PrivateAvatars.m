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

    NSData *data = UIImagePNGRepresentation(image);
    NSString *path = [[ProfileManager sharedInstance] pathInAvatarDirectoryForFileName:kUserAvatarFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:path]) {
        DDLogInfo(@"ToxManager+PrivateAvatars: old avatar exists, removing it");

        [fileManager removeItemAtPath:path error:nil];
    }

    if (data) {
        DDLogInfo(@"ToxManager+PrivateAvatars: setting new avatar...");

        while (data.length > TOX_AVATAR_MAX_DATA_LENGTH) {
            DDLogInfo(@"ToxManager+PrivateAvatars: setting new avatar... avatar is too big, resizing");

            CGSize newSize = CGSizeMake(image.size.width / 2.0, image.size.height / 2.0);

            UIGraphicsBeginImageContext(newSize);
            [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            data = UIImagePNGRepresentation(image);
        }

        [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent]
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

- (void)qIncomingAvatarInfoForFriend:(ToxFriend *)friend hash:(NSString *)hash
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    __weak ToxManager *weakSelf = self;

    [self qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
        if (user.avatarHash && [user.avatarHash isEqualToString:hash]) {
            DDLogInfo(@"ToxManager+PrivateAvatars: already have this avatar");
            return;
        }

        tox_request_avatar_data(weakSelf.tox, friend.id);
    }];
}

@end

#pragma mark -  C functions

void avatarInfoCallback(Tox *tox, int32_t friendnumber, uint8_t format, uint8_t *hash, void *userdata)
{
    DDLogCVerbose(@"ToxManager+PrivateAvatars: avatarInfoCallback with friendnumber %d format %d hash %s",
            friendnumber, format, hash);

    if (format == TOX_AVATAR_FORMAT_NONE) {
        DDLogCWarn(@"ToxManager+PrivateAvatars: wrong format, quiting");
        return;
    }

    ToxFriend *friend = [[ToxManager sharedInstance].friendsContainer friendWithId:friendnumber];

    NSString *hashString = [[NSString alloc] initWithBytes:hash
                                                    length:TOX_HASH_LENGTH
                                                  encoding:NSUTF8StringEncoding];

    dispatch_async([ToxManager sharedInstance].queue, ^{
        [[ToxManager sharedInstance] qIncomingAvatarInfoForFriend:friend hash:hashString];
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

}
