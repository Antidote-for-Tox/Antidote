//
//  ToxManager.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 18.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ToxFriendsContainer.h"

@interface ToxManager : NSObject

@property (strong, nonatomic, readonly) ToxFriendsContainer *friendsContainer;

+ (instancetype)sharedInstance;

- (void)bootstrapWithAddress:(NSString *)address port:(NSUInteger)port publicKey:(NSString *)publicKey;

- (NSString *)toxId;

- (void)approveFriendRequest:(ToxFriendRequest *)request wasError:(BOOL *)wasError;

@end
