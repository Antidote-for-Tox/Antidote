//
//  ToxManagerFriends.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 23.10.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxManagerFriends.h"
#import "ToxManager+Private.h"
#import "ToxManagerChats.h"
#import "ToxManagerFiles.h"
#import "ToxFriend+Private.h"
#import "ToxFunctions.h"
#import "UserInfoManager.h"
#import "EventsManager.h"
#import "AppDelegate.h"
#import "CoreDataManager.h"
#import "CDUser.h"

void friendRequestCallback(Tox *tox, const uint8_t * public_key, const uint8_t * data, uint16_t length, void *userdata);
void nameChangeCallback(Tox *tox, int32_t friendnumber, const uint8_t *newname, uint16_t length, void *userdata);
void statusMessageCallback(Tox *tox, int32_t friendnumber, const uint8_t *newstatus, uint16_t length, void *userdata);
void userStatusCallback(Tox *tox, int32_t friendnumber, uint8_t status, void *userdata);
void typingChangeCallback(Tox *tox, int32_t friendnumber, uint8_t isTyping, void *userdata);
void connectionStatusCallback(Tox *tox, int32_t friendnumber, uint8_t status, void *userdata);

@implementation ToxManagerFriends

#pragma mark -  Public

- (instancetype)initOnToxQueueWithToxManager:(ToxManager *)manager
{
    NSAssert([manager isOnToxManagerQueue], @"Must be on ToxManager queue");

    self = [super init];

    if (! self) {
        return nil;
    }

    DDLogInfo(@"ToxManagerFriends: registering callbacks");

    tox_callback_friend_request    (manager.tox, friendRequestCallback,    NULL);
    tox_callback_name_change       (manager.tox, nameChangeCallback,       NULL);
    tox_callback_status_message    (manager.tox, statusMessageCallback,    NULL);
    tox_callback_user_status       (manager.tox, userStatusCallback,       NULL);
    tox_callback_typing_change     (manager.tox, typingChangeCallback,     NULL);
    tox_callback_connection_status (manager.tox, connectionStatusCallback, NULL);

    DDLogInfo(@"ToxManagerFriends: creating friends container...");

    uint32_t friendsCount = tox_count_friendlist(manager.tox);
    uint32_t listSize = friendsCount * sizeof(int32_t);

    int32_t *friendsList = malloc(listSize);

    tox_get_friendlist(manager.tox, friendsList, listSize);

    NSMutableArray *friendsArray = [NSMutableArray new];

    for (NSUInteger index = 0; index < friendsCount; index++) {
        int32_t friendId = friendsList[index];

        [friendsArray addObject:[self qCreateFriendWithId:friendId]];
    }

    manager.friendsContainer =
        [[ToxFriendsContainer alloc] initWithFriendsArray:[friendsArray copy]];

    free(friendsList);

    return self;
}

- (void)qSendFriendRequestWithAddress:(NSString *)addressString message:(NSString *)messageString
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManagerFriends: send friendRequest...");

    if (! messageString.length) {
        messageString = NSLocalizedString(@"Please, add me", @"Tox empty message");
    }

    uint8_t *address = [ToxFunctions hexStringToBin:addressString];
    const char *message = [messageString cStringUsingEncoding:NSUTF8StringEncoding];

    int32_t result = tox_add_friend(
            [ToxManager sharedInstance].tox,
            address,
            (const uint8_t *)message,
            [messageString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);

    free(address);

    if (result > -1) {
        [[ToxManager sharedInstance] qSaveTox];

        [[ToxManager sharedInstance].friendsContainer private_addFriend:[self qCreateFriendWithId:result]];

        DDLogInfo(@"ToxManagerFriends: send friendRequest... success");
    }
    else {
        DDLogError(@"ToxManagerFriends: send friendRequest... error occured");
    }
}

- (void)qApproveFriendRequest:(ToxFriendRequest *)request withBlock:(void (^)(BOOL wasError))block
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManagerFriends: approve friendRequest...");

    uint8_t *clientId = [ToxFunctions hexStringToBin:request.clientId];
    int32_t friendId = tox_add_friend_norequest([ToxManager sharedInstance].tox, clientId);
    free(clientId);

    BOOL wasError = NO;

    if (friendId == -1) {
        wasError = YES;

        DDLogError(@"ToxManagerFriends: approve friendRequest... error occured");
    }
    else {
        [[ToxManager sharedInstance] qSaveTox];

        [[ToxManager sharedInstance].friendsContainer private_removeFriendRequest:request];
        [[ToxManager sharedInstance].friendsContainer private_addFriend:[self qCreateFriendWithId:friendId]];

        DDLogInfo(@"ToxManagerFriends: approve friendRequest... approved");
    }

    if (block) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(wasError);
        });
    }
}

- (void)qRemoveFriendRequest:(ToxFriendRequest *)request
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    if (! request) {
        return;
    }

    DDLogInfo(@"ToxManagerFriends: removing friendRequest");

    [[ToxManager sharedInstance].friendsContainer private_removeFriendRequest:request];
}

- (void)qRemoveFriend:(ToxFriend *)friend
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    if (! friend) {
        return;
    }

    DDLogInfo(@"ToxManagerFriends: removing friend");

    tox_del_friend([ToxManager sharedInstance].tox, friend.id);
    [[ToxManager sharedInstance] qSaveTox];

    [[ToxManager sharedInstance].friendsContainer private_removeFriend:friend];
}

- (void)qChangeNicknameTo:(NSString *)name forFriend:(ToxFriend *)friendToChange
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    __weak ToxManagerFriends *weakSelf = self;

    [[ToxManager sharedInstance].friendsContainer private_updateFriendWithId:friendToChange.id
                                                                 updateBlock:^(ToxFriend *friend)
    {
        if (! friend.clientId) {
            return;
        }

        friend.nickname = name;

        if (name.length) {
            [[ToxManager sharedInstance].managerChats qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
                [CoreDataManager editCDObjectWithBlock:^{
                    user.nickname = name;
                } completionQueue:nil completionBlock:nil];
            }];
        }
        else {
            [weakSelf qMaybeCreateNicknameForFriend:friend];
        }
    }];
}

#pragma mark -  Private

- (ToxFriend *)qCreateFriendWithId:(int32_t)friendId
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    if (! tox_friend_exists([ToxManager sharedInstance].tox, friendId)) {
        return nil;
    }

    DDLogInfo(@"ToxManagerFriends: creating friend with id %d", friendId);

    ToxFriend *friend = [ToxFriend new];
    friend.id = friendId;
    friend.status = ToxFriendStatusOffline;

    {
        uint8_t *clientId = malloc(TOX_CLIENT_ID_SIZE);

        int result = tox_get_client_id([ToxManager sharedInstance].tox, friendId, clientId);

        if (result == 0) {
            friend.clientId = [ToxFunctions clientIdToString:clientId];
            free(clientId);
        }
    }

    {
        uint8_t *name = malloc(TOX_MAX_NAME_LENGTH);
        int length = tox_get_name([ToxManager sharedInstance].tox, friendId, name);

        if (length > 0) {
            friend.realName = [NSString stringWithCString:(const char*)name encoding:NSUTF8StringEncoding];
            free(name);
        }
    }

    {
        uint64_t lastOnline = tox_get_last_online([ToxManager sharedInstance].tox, friendId);

        if (lastOnline > 0) {
            friend.lastSeenOnline = [NSDate dateWithTimeIntervalSince1970:lastOnline];
        }
    }

    friend.isTyping = tox_get_is_typing([ToxManager sharedInstance].tox, friendId);

    {
        if (friend.clientId) {
            __weak ToxManagerFriends *weakSelf = self;

            [[ToxManager sharedInstance].managerChats qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
                friend.nickname = user.nickname;

                [weakSelf qMaybeCreateNicknameForFriend:friend];
            }];
        }
    }

    [self qMaybeCreateNicknameForFriend:friend];

    return friend;
}

- (void)qMaybeCreateNicknameForFriend:(ToxFriend *)friend
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    if (friend.nickname.length) {
        return;
    }

    if (! friend.realName) {
        return;
    }

    friend.nickname = friend.realName;

    if (! friend.clientId) {
        return;
    }

    [[ToxManager sharedInstance].managerChats qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
        [CoreDataManager editCDObjectWithBlock:^{
            user.nickname = friend.realName;
        } completionQueue:nil completionBlock:nil];
    }];
}

@end

#pragma mark -  C functions

void friendRequestCallback(Tox *tox, const uint8_t * publicKey, const uint8_t * data, uint16_t length, void *userdata)
{
    DDLogCVerbose(@"ToxManagerFriends: friendRequestCallback");

    NSString *key = [ToxFunctions publicKeyToString:(uint8_t *)publicKey];
    NSString *message = [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];

    ToxFriendRequest *request = [ToxFriendRequest friendRequestWithPublicKey:key message:message];

    dispatch_async([ToxManager sharedInstance].queue, ^{
        [[ToxManager sharedInstance].friendsContainer private_addFriendRequest:request];

        dispatch_async(dispatch_get_main_queue(), ^{
            EventObject *object = [EventObject objectWithType:EventObjectTypeFriendRequest
                                                        image:nil
                                                       object:request];
            [[EventsManager sharedInstance] addObject:object];

            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate updateBadgeForTab:AppDelegateTabIndexFriends];
        });
    });
}

void nameChangeCallback(Tox *tox, int32_t friendnumber, const uint8_t *newname, uint16_t length, void *userdata)
{
    DDLogCVerbose(@"ToxManagerFriends: nameChangeCallback with friendnumber %d", friendnumber);

    NSString *realName = [NSString stringWithCString:(const char*)newname encoding:NSUTF8StringEncoding];

    dispatch_async([ToxManager sharedInstance].queue, ^{
        [[ToxManager sharedInstance].friendsContainer private_updateFriendWithId:friendnumber
                                                                     updateBlock:^(ToxFriend *friend)
        {
            friend.realName = realName;

            [[ToxManager sharedInstance].managerFriends qMaybeCreateNicknameForFriend:friend];
        }];
    });
}

void statusMessageCallback(Tox *tox, int32_t friendnumber, const uint8_t *newstatus, uint16_t length, void *userdata)
{
    DDLogCVerbose(@"ToxManagerFriends: statusMessageCallback with friendnumber %d", friendnumber);

    NSString *statusMessage = [NSString stringWithCString:(const char*)newstatus encoding:NSUTF8StringEncoding];

    dispatch_async([ToxManager sharedInstance].queue, ^{
        [[ToxManager sharedInstance].friendsContainer private_updateFriendWithId:friendnumber
                                                                     updateBlock:^(ToxFriend *friend)
        {
            friend.statusMessage = statusMessage;
        }];
    });
}

void userStatusCallback(Tox *tox, int32_t friendnumber, uint8_t status, void *userdata)
{
    DDLogCVerbose(@"ToxManagerFriends: userStatusCallback with friendnumber %d status %d", friendnumber, status);

    dispatch_async([ToxManager sharedInstance].queue, ^{
        ToxFriendStatus friendStatus = ToxFriendStatusOffline;

        if (status == TOX_USERSTATUS_NONE) {
            friendStatus = ToxFriendStatusOnline;
        }
        else if (status == TOX_USERSTATUS_AWAY) {
            friendStatus = ToxFriendStatusAway;
        }
        else if (status == TOX_USERSTATUS_BUSY) {
            friendStatus = ToxFriendStatusBusy;
        }
        else if (status == TOX_USERSTATUS_INVALID) {
            friendStatus = ToxFriendStatusOffline;
        }

        [[ToxManager sharedInstance].friendsContainer private_updateFriendWithId:friendnumber
                                                                     updateBlock:^(ToxFriend *friend)
        {
            friend.status = friendStatus;
        }];
    });
}

void typingChangeCallback(Tox *tox, int32_t friendnumber, uint8_t isTyping, void *userdata)
{
    dispatch_async([ToxManager sharedInstance].queue, ^{
        [[ToxManager sharedInstance].friendsContainer private_updateFriendWithId:friendnumber
                                                                     updateBlock:^(ToxFriend *friend)
        {
            friend.isTyping = (isTyping == 1);
        }];
    });
}

void connectionStatusCallback(Tox *tox, int32_t friendnumber, uint8_t status, void *userdata)
{
    DDLogCVerbose(@"ToxManagerFriends: connectionStatusCallback with friendnumber %d status %d", friendnumber, status);

    dispatch_async([ToxManager sharedInstance].queue, ^{
        if (status == 0) {
            [[ToxManager sharedInstance].friendsContainer private_updateFriendWithId:friendnumber
                                                                         updateBlock:^(ToxFriend *friend)
            {
                friend.status = ToxFriendStatusOffline;
            }];
        }

        [[ToxManager sharedInstance] qSaveTox];
    });
}

