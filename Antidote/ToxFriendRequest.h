//
//  ToxFriendRequest.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToxFriendRequest : NSObject

@property (strong, nonatomic) NSString *publicKey;
@property (strong, nonatomic) NSString *message;
@property (assign, nonatomic) BOOL wasSeen;

+ (ToxFriendRequest *)friendRequestWithPublicKey:(NSString *)publicKey message:(NSString *)message;

- (NSString *)clientId;

+ (ToxFriendRequest *)friendRequestFromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)requestToDictionary;

@end
