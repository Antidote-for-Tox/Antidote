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
static NSString *const kWasSeenKey = @"kWasSeenKey";

@implementation ToxFriendRequest

+ (ToxFriendRequest *)friendRequestWithPublicKey:(NSString *)publicKey message:(NSString *)message
{
    ToxFriendRequest *request = [ToxFriendRequest new];

    request.publicKey = publicKey;
    request.message = message;
    request.wasSeen = NO;

    return request;
}

- (NSString *)clientId
{
    if (self.publicKey.length < TOX_CLIENT_ID_SIZE * 2) {
        return nil;
    }
    else {
        return [self.publicKey substringToIndex:TOX_CLIENT_ID_SIZE * 2];
    }
}

+ (ToxFriendRequest *)friendRequestFromDictionary:(NSDictionary *)dictionary
{
    ToxFriendRequest *request = [ToxFriendRequest new];

    request.publicKey = dictionary[kPublicKeyKey];
    request.message = dictionary[kMessageKey];
    request.wasSeen = [dictionary[kWasSeenKey] boolValue];

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

    dict[kWasSeenKey] = @(self.wasSeen);

    return dict;
}

@end
