//
//  OCTSubmanagerFriends.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 15.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OCTFriendsContainer.h"
#import "OCTFriendRequest.h"
#import "OCTArray.h"

@interface OCTSubmanagerFriends : NSObject

/**
 * Container with all friends.
 */
@property (strong, nonatomic, readonly) OCTFriendsContainer *friendsContainer;

/**
 * Returns OCTArray with all friend requests.
 *
 * @return Autoupdating array with all friend requests.
 */
- (OCTArray *)allFriendRequests;

/**
 * This adds friend to the list.
 * address and message are required.
 *
 * TODO write documentation
 */
- (BOOL)sendFriendRequestToAddress:(NSString *)address message:(NSString *)message error:(NSError **)error;

/**
 * TODO write documentation
 */
- (BOOL)approveFriendRequest:(OCTFriendRequest *)friendRequest error:(NSError **)error;

/**
 * TODO write documentation
 */
- (BOOL)removeFriendRequest:(OCTFriendRequest *)friendRequest;

/**
 * TODO write documentation
 */
- (BOOL)removeFriend:(OCTFriend *)friend error:(NSError **)error;

@end
