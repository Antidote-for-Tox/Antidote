//
//  ToxFriendsManager.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ToxFriend.h"

/**
 * userInfo will contain dictionary with following keys:
 * kToxFriendsManagerUpdateKeyInsertedSet - NSIndexSet with indexes of objects, that were inserted
 */
extern NSString *const kToxFriendsManagerUpdateNotification;
extern NSString *const kToxFriendsManagerUpdateKeyInsertedSet;

@interface ToxFriendsManager : NSObject

- (NSUInteger)count;
- (ToxFriend *)friendAtIndex:(NSUInteger)index;

@end


/**
 * Private methods for ToxFriendsManager. You want to use public API, not this methods. They are for ToxManager.
 */
@interface ToxFriendsManager(Private)

- (void)private_addFriendRequest:(NSString *)publicKey;

@end
