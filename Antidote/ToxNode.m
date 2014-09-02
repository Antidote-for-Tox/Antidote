//
//  ToxNode.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 9/2/14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxNode.h"

@implementation ToxNode

+ (ToxNode *)nodeWithAddress:(NSString *)address port:(NSUInteger)port publicKey:(NSString *)publicKey
{
    ToxNode *node = [ToxNode new];

    node.address = address;
    node.port = port;
    node.publicKey = publicKey;

    return node;
}

@end
