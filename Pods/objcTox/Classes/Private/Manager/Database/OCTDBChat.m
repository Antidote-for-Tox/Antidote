//
//  OCTDBChat.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 27.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTDBChat.h"

@implementation OCTDBChat

+ (NSString *)primaryKey
{
    return @"uniqueIdentifier";
}

+ (NSDictionary *)defaultPropertyValues
{
    return @{
        @"uniqueIdentifier" : [[NSUUID UUID] UUIDString],
        @"enteredText" : @"",
    };
}

@end
