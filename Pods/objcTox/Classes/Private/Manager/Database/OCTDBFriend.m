//
//  OCTDBFriend.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 27.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Realm/Realm.h>
#import "OCTDBFriend.h"

@implementation OCTDBFriend

+ (NSString *)primaryKey
{
    return @"friendNumber";
}

@end
