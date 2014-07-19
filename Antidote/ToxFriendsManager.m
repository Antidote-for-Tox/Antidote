//
//  ToxFriendsManager.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxFriendsManager.h"
#import "UserInfoManager.h"

NSString *const kToxFriendsManagerUpdateRequestsNotification = @"kToxFriendsManagerUpdateRequestsNotification";
NSString *const kToxFriendsManagerUpdateKeyInsertedSet = @"kToxFriendsManagerUpdateKeyInsertedSet";

@interface ToxFriendsManager()

@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) NSMutableArray *friendRequests;

@end

@implementation ToxFriendsManager

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.friends = [NSMutableArray new];
        self.friendRequests = [NSMutableArray new];

        for (NSDictionary *dict in [UserInfoManager sharedInstance].uPendingFriendRequests) {
            ToxFriendRequest *request = [ToxFriendRequest friendRequestFromDictionary:dict];

            [self.friendRequests addObject:request];
        }
    }

    return self;
}

#pragma mark -  Public

- (NSUInteger)friendsCount
{
    @synchronized(self.friends) {
        return self.friends.count;
    }
}

- (ToxFriend *)friendAtIndex:(NSUInteger)index
{
    @synchronized(self.friends) {
        if (index < self.friends.count) {
            return self.friends[index];
        }

        return nil;
    }
}

- (NSUInteger)requestsCount
{
    @synchronized(self.friendRequests) {
        return self.friendRequests.count;
    }
}

- (ToxFriendRequest *)requestAtIndex:(NSUInteger)index
{
    @synchronized(self.friendRequests) {
        if (index < self.friendRequests.count) {
            return self.friendRequests[index];
        }

        return nil;
    }
}

#pragma mark -  Private for ToxManager

- (void)private_addFriendRequest:(NSString *)publicKey message:(NSString *)message
{
    if (! publicKey) {
        return;
    }

    ToxFriendRequest *request = [ToxFriendRequest friendRequestWithPublicKey:publicKey message:message];

    NSArray *pendingRequests = [UserInfoManager sharedInstance].uPendingFriendRequests;

    for (NSDictionary *dict in pendingRequests) {
        ToxFriendRequest *r = [ToxFriendRequest friendRequestFromDictionary:dict];

        if ([r.clientId isEqual:request.clientId]) {
            // already added this request
            return;
        }
    }

    NSMutableArray *array = [NSMutableArray arrayWithArray:pendingRequests];
    [array addObject:[request requestToDictionary]];
    [UserInfoManager sharedInstance].uPendingFriendRequests = [array copy];

    @synchronized(self.friendRequests) {
        [self.friendRequests addObject:request];

        NSIndexSet *inserted = [NSIndexSet indexSetWithIndex:self.friendRequests.count-1];
        [self sendUpdateFriendRequestsNotificationWithInsertedSet:inserted];
    }
}

#pragma mark -  Private

- (void)sendUpdateFriendRequestsNotificationWithInsertedSet:(NSIndexSet *)inserted
{
    NSMutableDictionary *userInfo = [NSMutableDictionary new];

    if (inserted) {
        userInfo[kToxFriendsManagerUpdateKeyInsertedSet] = inserted;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kToxFriendsManagerUpdateRequestsNotification
                                                            object:nil
                                                          userInfo:[userInfo copy]];
    });
}

@end
