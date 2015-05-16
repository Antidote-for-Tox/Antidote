//
//  OCTFriend.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 10.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OCTToxConstants.h"

/**
 * Class that represents friend (or just simply contact).
 */
@interface OCTFriend : NSObject

/**
 * Friend number that is unique for Tox.
 * In case if friend will be deleted, old id may be reused on new friend creation.
 */
@property (assign, nonatomic, readonly) OCTToxFriendNumber friendNumber;

/**
 * Public key of a friend, is kOCTToxPublicKeyLength length.
 * Is constant, cannot be changed.
 */
@property (copy, nonatomic, readonly) NSString *publicKey;

/**
 * Name of a friend.
 */
@property (copy, nonatomic, readonly) NSString *name;

/**
 * Status message of a friend.
 */
@property (copy, nonatomic, readonly) NSString *statusMessage;

/**
 * Status message of a friend.
 */
@property (assign, nonatomic, readonly) OCTToxUserStatus status;

/**
 * Connection status message of a friend.
 */
@property (assign, nonatomic, readonly) OCTToxConnectionStatus connectionStatus;

/**
 * The date when friend was last seen online. Contains actual information in case if friend has connectionStatus offline.
 */
@property (strong, nonatomic, readonly) NSDate *lastSeenOnline;

/**
 * Whether friend is typing now in current chat.
 */
@property (assign, nonatomic, readonly) BOOL isTyping;

@end
