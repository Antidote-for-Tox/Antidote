//
//  ToxFriend.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxFriend.h"
#import "tox.h"

@implementation ToxFriend

+ (ToxFriend *)friendWithPublicKey:(NSString *)publicKey
{
    ToxFriend *friend = [ToxFriend new];

    friend.publicKey = publicKey;

    return friend;
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

@end
