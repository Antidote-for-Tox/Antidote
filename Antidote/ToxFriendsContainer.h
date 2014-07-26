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
 * kToxFriendsContainerUpdateKeyInsertedSet - NSIndexSet with indexes of objects, that were inserted
 * kToxFriendsContainerUpdateKeyInsertedSet - NSIndexSet with indexes of objects, that were removed
 */
extern NSString *const kToxFriendsContainerUpdateRequestsNotification;
extern NSString *const kToxFriendsContainerUpdateKeyInsertedSet;
extern NSString *const kToxFriendsContainerUpdateKeyRemovedSet;

@interface ToxFriendsContainer : NSObject

- (NSUInteger)friendsCount;
- (ToxFriend *)friendAtIndex:(NSUInteger)index;

- (NSUInteger)requestsCount;
- (ToxFriendRequest *)requestAtIndex:(NSUInteger)index;

@end


/**
 * Private methods for ToxFriendsContainer. You want to use public API, not this methods. They are for ToxManager.
 */
@interface ToxFriendsContainer(Private)

- (instancetype)initWithFriendsArray:(NSArray *)friends;

- (void)private_addFriend:(ToxFriend *)friend;

- (void)private_addFriendRequest:(ToxFriendRequest *)request;
- (void)private_removeFriendRequest:(ToxFriendRequest *)request;

@end
