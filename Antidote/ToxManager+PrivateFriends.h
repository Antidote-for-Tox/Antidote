//
//  ToxManager+PrivateFriends.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 15.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxManager.h"

@interface ToxManager (PrivateFriends)

- (void)qRegisterFriendsCallbacks;

- (void)qLoadFriendsAndCreateContainer;
- (void)qSendFriendRequestWithAddress:(NSString *)addressString message:(NSString *)messageString;
- (void)qApproveFriendRequest:(ToxFriendRequest *)request withBlock:(void (^)(BOOL wasError))block;
- (void)qRemoveFriendRequest:(ToxFriendRequest *)request;
- (void)qRemoveFriend:(ToxFriend *)friend;
- (void)qChangeAssociatedNameTo:(NSString *)name forFriend:(ToxFriend *)friendToChange;

@end
