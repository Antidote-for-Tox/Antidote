//
//  OCTFriendRequest.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 16.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCTFriendRequest : NSObject

/**
 * Public key of a friend.
 */
@property (strong, nonatomic) NSString *publicKey;

/**
 * Message that friend did send with friend request.
 */
@property (strong, nonatomic) NSString *message;

/**
 * Date when friend request was received
 */
@property (strong, nonatomic) NSDate *date;

@end
