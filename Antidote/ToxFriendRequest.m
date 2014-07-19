//
//  ToxFriendRequest.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxFriendRequest.h"
#import "tox.h"

static NSString *const kPublicKeyKey = @"kPublicKeyKey";
static NSString *const kMessageKey = @"kMessageKey";

@implementation ToxFriendRequest

+ (ToxFriendRequest *)friendRequestWithPublicKey:(NSString *)publicKey message:(NSString *)message
{
    ToxFriendRequest *request = [ToxFriendRequest new];

    request.publicKey = publicKey;
    request.message = message;

    return request;
}

- (NSString *)clientId
{
    if (self.publicKey.length < TOX_CLIENT_ID_SIZE) {
        return nil;
    }
    else {
        return [self.publicKey substringToIndex:TOX_CLIENT_ID_SIZE];
    }
}

+ (ToxFriendRequest *)friendRequestFromDictionary:(NSDictionary *)dictionary
{
    ToxFriendRequest *request = [ToxFriendRequest new];

    request.publicKey = dictionary[kPublicKeyKey];
    request.message = dictionary[kMessageKey];

    return request;
}

- (NSDictionary *)requestToDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary new];

    if (self.publicKey) {
        dict[kPublicKeyKey] = self.publicKey;
    }
    if (self.message) {
        dict[kMessageKey] = self.message;
    }

    return dict;
}

@end
