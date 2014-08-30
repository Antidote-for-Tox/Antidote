//
//  ToxFriendsContainer.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxFriendsContainer.h"
#import "UserInfoManager.h"

NSString *const kToxFriendsContainerUpdateSpecificFriendNotification = @"kToxFriendsContainerUpdateSpecificFriendNotification";
NSString *const kToxFriendsContainerUpdateKeyFriend = @"kToxFriendsContainerUpdateKeyFriend";
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

        self.friendsSort = [[UserInfoManager sharedInstance].uFriendsSort unsignedIntegerValue];

        DDLogInfo(@"ToxFriendsContainer: created with number of friends %lu, number of friendRequests %lu",
                self.friends.count, self.friendRequests.count);
    }

    return self;
}

#pragma mark -  Properties

- (void)setFriendsSort:(ToxFriendsContainerSort)sort
{
    _friendsSort = sort;

    [UserInfoManager sharedInstance].uFriendsSort = @(sort);

    @synchronized(self.friends) {
        if (self.friends.count <= 1) {
            return;
        }

        [self.friends sortUsingComparator:[self comparatorForCurrentSort]];

        NSRange range = NSMakeRange(0, self.friends.count);
        [self sendUpdateNotificationWithType:kToxFriendsContainerUpdateFriendsNotification
                                 insertedSet:nil
                                  removedSet:nil
                                  updatedSet:[NSIndexSet indexSetWithIndexesInRange:range]];
    }
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

- (ToxFriend *)friendWithClientId:(NSString *)clientId
{
    if (! clientId) {
        return nil;
    }

    @synchronized(self.friends) {
        for (ToxFriend *friend in self.friends) {
            if ([friend.clientId isEqual:clientId]) {
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
    DDLogInfo(@"ToxFriendsContainer: adding friend %@ with id %d...", friend, friend.id);

    if (! friend) {
        DDLogError(@"ToxFriendsContainer: adding friend... no friend, quiting");
        return;
    }

    @synchronized(self.friends) {
        NSUInteger index = [self.friends indexOfObject:friend];

        if (index != NSNotFound) {
            DDLogWarn(@"ToxFriendsContainer: adding friend... friend already exist");
            return;
        }

        NSIndexSet *inserted = [NSIndexSet indexSetWithIndex:self.friends.count];

        [self.friends addObject:friend];

        [self sendUpdateNotificationWithType:kToxFriendsContainerUpdateFriendsNotification
                                 insertedSet:inserted
                                  removedSet:nil
                                  updatedSet:nil];

        DDLogInfo(@"ToxFriendsContainer: adding friend... added");
    }
}

- (void)private_updateFriendWithId:(int32_t)id updateBlock:(void (^)(ToxFriend *friend))updateBlock
{
    if (! updateBlock) {
        return;
    }

    @synchronized(self.friends) {
        DDLogInfo(@"ToxFriendsContainer: updating friend with id %d...", id);

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
            DDLogError(@"ToxFriendsContainer: updating friend with id %d... not found", id);
            return;
        }

        updateBlock(friend);

        [self.friends removeObjectAtIndex:index];

        NSUInteger newIndex = [self.friends indexOfObject:friend
                                            inSortedRange:NSMakeRange(0, self.friends.count)
                                                  options:NSBinarySearchingInsertionIndex
                                          usingComparator:[self comparatorForCurrentSort]];

        [self.friends insertObject:friend atIndex:newIndex];

        NSIndexSet *inserted, *removed, *updated;

        if (index == newIndex) {
            updated = [NSIndexSet indexSetWithIndex:index];
        }
        else {
            inserted = [NSIndexSet indexSetWithIndex:newIndex];
            removed = [NSIndexSet indexSetWithIndex:index];
        }

        [self sendUpdateNotificationWithType:kToxFriendsContainerUpdateFriendsNotification
                                 insertedSet:inserted
                                  removedSet:removed
                                  updatedSet:updated];

        [self sendUpdateFriendWithIdNotification:friend];

        DDLogInfo(@"ToxFriendsContainer: updating friend with id %d... updated", id);
    }
}

- (void)private_removeFriend:(ToxFriend *)friend
{
    if (! friend) {
        return;
    }

    @synchronized(self.friends) {
        DDLogInfo(@"ToxFriendsContainer: removing friend with id %d...", friend.id);

        NSUInteger index = [self.friends indexOfObject:friend];

        if (index == NSNotFound) {
            DDLogError(@"ToxFriendsContainer: removing friend with id %d... not found", friend.id);
            return;
        }

        NSIndexSet *removed = [NSIndexSet indexSetWithIndex:index];
        [self.friends removeObjectAtIndex:index];

        [self sendUpdateNotificationWithType:kToxFriendsContainerUpdateFriendsNotification
                                 insertedSet:nil
                                  removedSet:removed
                                  updatedSet:nil];

        DDLogInfo(@"ToxFriendsContainer: removing friend with id %d... removed", friend.id);
    }
}

- (void)private_addFriendRequest:(ToxFriendRequest *)request
{
    if (! request.clientId) {
        return;
    }

    DDLogInfo(@"ToxFriendsContainer: adding friendRequest...");

    NSArray *pendingRequests = [UserInfoManager sharedInstance].uPendingFriendRequests;

    NSUInteger index = [self indexOfClientId:request.clientId inPendingRequestsArray:pendingRequests];

    if (index != NSNotFound) {
        // already added this request
        DDLogWarn(@"ToxFriendsContainer: adding friendRequest... already added");
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

        DDLogInfo(@"ToxFriendsContainer: adding friendRequest... added");
    }
}

- (void)private_removeFriendRequest:(ToxFriendRequest *)request
{
    if (! request.clientId) {
        return;
    }

    DDLogInfo(@"ToxFriendsContainer: removing friendRequest...");

    NSArray *pendingRequests = [UserInfoManager sharedInstance].uPendingFriendRequests;

    NSUInteger index = [self indexOfClientId:request.clientId inPendingRequestsArray:pendingRequests];

    if (index == NSNotFound) {
        DDLogError(@"ToxFriendsContainer: removing friendRequest... not found");
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

        DDLogInfo(@"ToxFriendsContainer: removing friendRequest... removed");
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

- (void)sendUpdateFriendWithIdNotification:(ToxFriend *)friend
{
    if (! friend) {
        return;
    }

    NSDictionary *userInfo = @{
        kToxFriendsContainerUpdateKeyFriend : friend,
    };

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kToxFriendsContainerUpdateSpecificFriendNotification
                                                            object:nil
                                                          userInfo:userInfo];
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

- (NSComparator)comparatorForCurrentSort
{
    NSComparator nameComparator = ^NSComparisonResult (ToxFriend *first, ToxFriend *second) {
        if (first.associatedName && second.associatedName) {
            return [first.associatedName compare:second.associatedName];
        }

        if (first.associatedName) {
            return NSOrderedDescending;
        }
        if (second.associatedName) {
            return NSOrderedAscending;
        }

        return [first.clientId compare:second.clientId];
    };

    NSComparator comparator;

    if (self.friendsSort == ToxFriendsContainerSortByName) {
        comparator = nameComparator;
    }
    else if (self.friendsSort == ToxFriendsContainerSortByStatus) {
        comparator = ^NSComparisonResult (ToxFriend *first, ToxFriend *second) {
            if (first.status == second.status) {
                return nameComparator(first, second);
            }

            if (first.status > second.status) {
                return NSOrderedDescending;
            }

            return NSOrderedAscending;
        };
    }

    return comparator;
}

@end
