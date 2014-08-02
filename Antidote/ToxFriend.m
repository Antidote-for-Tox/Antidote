//
//  ToxFriend.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxFriend.h"
#import "ToxFriend+Private.h"

@implementation ToxFriend

- (BOOL)isEqual:(id)object
{
    if (! [object isKindOfClass:[ToxFriend class]]) {
        return NO;
    }

    ToxFriend *friend = object;

    return friend.id == self.id;
}

- (NSUInteger)hash
{
    return self.id;
}

@end
