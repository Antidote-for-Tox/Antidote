//
//  ToxManager.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 18.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ToxFriendsManager.h"

static const int32_t kToxBadFriendId = -1;

@interface ToxManager : NSObject

@property (strong, nonatomic, readonly) ToxFriendsManager *friendsManager;

+ (instancetype)sharedInstance;

- (void)bootstrapWithAddress:(NSString *)address port:(NSUInteger)port publicKey:(NSString *)publicKey;

- (NSString *)toxId;

/**
 * Returns friend id.
 */
- (int32_t)approveFriendRequest:(ToxFriendRequest *)request;

@end
