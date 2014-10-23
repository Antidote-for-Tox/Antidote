//
//  ToxManagerFriends.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 23.10.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ToxManager.h"
#import "ToxFriendRequest.h"
#import "ToxFriend.h"

@interface ToxManagerFriends : NSObject

- (void)qSetupWithToxManager:(ToxManager *)manager;

- (void)qSendFriendRequestWithAddress:(NSString *)addressString message:(NSString *)messageString;
- (void)qApproveFriendRequest:(ToxFriendRequest *)request withBlock:(void (^)(BOOL wasError))block;
- (void)qRemoveFriendRequest:(ToxFriendRequest *)request;
- (void)qRemoveFriend:(ToxFriend *)friend;
- (void)qChangeNicknameTo:(NSString *)name forFriend:(ToxFriend *)friendToChange;

@end
