//
//  ToxFriendsContainer.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ToxFriend.h"
#import "ToxFriendRequest.h"

/**
 * userInfo will contain dictionary with following keys:
 * kToxFriendsContainerUpdateKeyFriend - appropriate ToxFriend
 */
extern NSString *const kToxFriendsContainerUpdateSpecificFriendNotification;
extern NSString *const kToxFriendsContainerUpdateKeyFriend;

/**
 * userInfo will contain dictionary with following keys:
 * kToxFriendsContainerUpdateKeyInsertedSet - NSIndexSet with indexes of objects, that were inserted
 * kToxFriendsContainerUpdateKeyRemovedSet - NSIndexSet with indexes of objects, that were removed
 * kToxFriendsContainerUpdateKeyUpdatedSet - NSIndexSet with indexes of objects, that were updated
 */
extern NSString *const kToxFriendsContainerUpdateFriendsNotification;

/**
 * userInfo will contain dictionary with following keys:
 * kToxFriendsContainerUpdateKeyInsertedSet - NSIndexSet with indexes of objects, that were inserted
 * kToxFriendsContainerUpdateKeyRemovedSet - NSIndexSet with indexes of objects, that were removed
 */
extern NSString *const kToxFriendsContainerUpdateRequestsNotification;

extern NSString *const kToxFriendsContainerUpdateKeyInsertedSet;
extern NSString *const kToxFriendsContainerUpdateKeyRemovedSet;
extern NSString *const kToxFriendsContainerUpdateKeyUpdatedSet;

typedef NS_ENUM(NSUInteger, ToxFriendsContainerSort) {
    ToxFriendsContainerSortByName = 0,
    ToxFriendsContainerSortByStatus,
};

@interface ToxFriendsContainer : NSObject

@property (assign, nonatomic) ToxFriendsContainerSort friendsSort;

- (NSUInteger)friendsCount;
- (ToxFriend *)friendAtIndex:(NSUInteger)index;
- (ToxFriend *)friendWithId:(int32_t)id;
- (ToxFriend *)friendWithClientId:(NSString *)clientId;

- (NSUInteger)requestsCount;
- (ToxFriendRequest *)requestAtIndex:(NSUInteger)index;

@end


/**
 * Private methods for ToxFriendsContainer. You want to use public API, not this methods. They are for ToxManager.
 */
@interface ToxFriendsContainer(Private)

- (instancetype)initWithFriendsArray:(NSArray *)friends;

- (void)private_addFriend:(ToxFriend *)friend;
- (void)private_updateFriendWithId:(int32_t)id updateBlock:(void (^)(ToxFriend *friend))updateBlock;
- (void)private_removeFriend:(ToxFriend *)friend;

- (void)private_addFriendRequest:(ToxFriendRequest *)request;
- (void)private_removeFriendRequest:(ToxFriendRequest *)request;

@end
