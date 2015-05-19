//
//  OCTConverterFriendRequest.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 02.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTConverterFriendRequest.h"
#import "OCTFriendRequest.h"
#import "OCTDBFriendRequest.h"

@implementation OCTConverterFriendRequest

#pragma mark -  OCTConverterProtocol

- (NSString *)objectClassName
{
    return NSStringFromClass([OCTFriendRequest class]);
}

- (OCTFriendRequest *)objectFromRLMObject:(OCTDBFriendRequest *)db
{
    NSParameterAssert(db);

    OCTFriendRequest *friendRequest = [OCTFriendRequest new];
    friendRequest.publicKey = db.publicKey;
    friendRequest.message = db.message;
    friendRequest.date = [NSDate dateWithTimeIntervalSince1970:db.dateInterval];

    return friendRequest;
}

- (RLMSortDescriptor *)rlmSortDescriptorFromDescriptor:(OCTSortDescriptor *)descriptor
{
    NSParameterAssert(descriptor);

    return [RLMSortDescriptor sortDescriptorWithProperty:descriptor.property ascending:descriptor.ascending];
}

@end
