//
//  ToxFriendsContainer.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxFriendsContainer.h"
#import "UserInfoManager.h"

NSString *const kToxFriendsContainerUpdateFriendsNotification = @"kToxFriendsContainerUpdateFriendsNotification";
NSString *const kToxFriendsContainerUpdateRequestsNotification = @"kToxFriendsContainerUpdateRequestsNotification";
NSString *const kToxFriendsContainerUpdateKeyInsertedSet = @"kToxFriendsContainerUpdateKeyInsertedSet";
NSString *const kToxFriendsContainerUpdateKeyRemovedSet = @"kToxFriendsContainerUpdateKeyRemovedSet";
NSString *const kToxFriendsContainerUpdateKeyUpdatedSet = @"kToxFriendsContainerUpdateKeyUpdatedSet";

@interface ToxFriendsContainer()

@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) NSMutableArray *friendRequests;

@end

@implementation ToxFriendsContainer

#pragma mark -  Lifecycle

- (instancetype)initWithFriendsArray:(NSArray *)friends
{
    self = [super init];

    if (self) {
        self.friends = [NSMutableArray arrayWithArray:friends];
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

- (ToxFriend *)friendWithId:(int32_t)id
{
    @synchronized(self.friends) {
        for (ToxFriend *friend in self.friends) {
            if (friend.id == id) {
                return friend;
            }
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

- (void)private_addFriend:(ToxFriend *)friend
{
    @synchronized(self.friends) {
        NSUInteger index = [self.friends indexOfObject:friend];

        if (index != NSNotFound) {
            return;
        }

        NSIndexSet *inserted = [NSIndexSet indexSetWithIndex:self.friends.count];

        [self.friends addObject:friend];

        [self sendUpdateNotificationWithType:kToxFriendsContainerUpdateFriendsNotification
                                 insertedSet:inserted
                                  removedSet:nil
                                  updatedSet:nil];
    }
}

- (void)private_updateFriendWithId:(int32_t)id updateBlock:(void (^)(ToxFriend *friend))updateBlock
{
    if (! updateBlock) {
        return;
    }

    @synchronized(self.friends) {
        NSUInteger index = NSNotFound;
        ToxFriend *friend = nil;

        for (NSUInteger i = 0; i < self.friends.count; i++) {
            ToxFriend *f = self.friends[i];

            if (f.id == id) {
                index = i;
                friend = f;
                break;
            }
        }

        if (index == NSNotFound) {
            return;
        }

        updateBlock(friend);

        [self sendUpdateNotificationWithType:kToxFriendsContainerUpdateFriendsNotification
                                 insertedSet:nil
                                  removedSet:nil
                                  updatedSet:[NSIndexSet indexSetWithIndex:index]];
    }
}

- (void)private_addFriendRequest:(ToxFriendRequest *)request
{
    if (! request.clientId) {
        return;
    }

    NSArray *pendingRequests = [UserInfoManager sharedInstance].uPendingFriendRequests;

    NSUInteger index = [self indexOfClientId:request.clientId inPendingRequestsArray:pendingRequests];

    if (index != NSNotFound) {
        // already added this request
        return;
    }

    NSMutableArray *array = [NSMutableArray arrayWithArray:pendingRequests];
    [array addObject:[request requestToDictionary]];
    [UserInfoManager sharedInstance].uPendingFriendRequests = [array copy];

    @synchronized(self.friendRequests) {
        [self.friendRequests addObject:request];

        NSIndexSet *inserted = [NSIndexSet indexSetWithIndex:self.friendRequests.count-1];
        [self sendUpdateNotificationWithType:kToxFriendsContainerUpdateRequestsNotification
                                 insertedSet:inserted
                                  removedSet:nil
                                  updatedSet:nil];
    }
}

- (void)private_removeFriendRequest:(ToxFriendRequest *)request
{
    if (! request.clientId) {
        return;
    }

    NSArray *pendingRequests = [UserInfoManager sharedInstance].uPendingFriendRequests;

    NSUInteger index = [self indexOfClientId:request.clientId inPendingRequestsArray:pendingRequests];

    if (index == NSNotFound) {
        return;
    }

    NSMutableArray *array = [NSMutableArray arrayWithArray:pendingRequests];
    [array removeObjectAtIndex:index];
    [UserInfoManager sharedInstance].uPendingFriendRequests = [array copy];

    @synchronized(self.friendRequests) {
        [self.friendRequests removeObjectAtIndex:index];

        NSIndexSet *removed = [NSIndexSet indexSetWithIndex:index];
        [self sendUpdateNotificationWithType:kToxFriendsContainerUpdateRequestsNotification
                                 insertedSet:nil
                                  removedSet:removed
                                  updatedSet:nil];
    }
}

#pragma mark -  Private

- (void)sendUpdateNotificationWithType:(NSString *)type
                           insertedSet:(NSIndexSet *)inserted
                            removedSet:(NSIndexSet *)removed
                            updatedSet:(NSIndexSet *)updated
{
    NSMutableDictionary *userInfo = [NSMutableDictionary new];

    if (inserted) {
        userInfo[kToxFriendsContainerUpdateKeyInsertedSet] = inserted;
    }

    if (removed) {
        userInfo[kToxFriendsContainerUpdateKeyRemovedSet] = removed;
    }

    if (updated) {
        userInfo[kToxFriendsContainerUpdateKeyUpdatedSet] = updated;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:type
                                                            object:nil
                                                          userInfo:[userInfo copy]];
    });
}

- (NSUInteger)indexOfClientId:(NSString *)clientId inPendingRequestsArray:(NSArray *)pendingRequests
{
    if (! clientId) {
        return NSNotFound;
    }

    for (NSUInteger i = 0; i < pendingRequests.count; i++) {
        NSDictionary *dict = pendingRequests[i];

        ToxFriendRequest *r = [ToxFriendRequest friendRequestFromDictionary:dict];

        if ([r.clientId isEqual:clientId]) {
            return i;
        }
    }

    return NSNotFound;
}

@end
