//
//  ToxListener.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 28.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OCTManager.h"

extern NSString *const kToxListenerGroupIdentifierFriendRequest;

/**
 * ToxListener subscribes to different OCTManager updates and send notifications,
 * shows connecting status, etc.
 *
 * For friend request update group identifier is kToxListenerGroupIdentifierFriendRequest.
 * For messages friend identifier is chat uniqueIdentifier.
 */
@interface ToxListener : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * Inits with manager listen to.
 */
- (instancetype)initWithManager:(OCTManager *)manager;

/**
 * Updates interface with current tox manager (connection status, tabbar badges, app icon badge etc).
 */
- (void)performUpdates;

@end
