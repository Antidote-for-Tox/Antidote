//
//  CoreDataManager+Chat.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CoreDataManager+Chat.h"
#import "CoreData+MagicalRecord.h"

@implementation CoreDataManager (Chat)

+ (NSArray *)allChatsSortedByDate
{
    __block NSArray *array;

    dispatch_sync([self private_queue], ^{
        array = [CDChat MR_findAllSortedBy:@"lastMessage.date" ascending:YES inContext:[self private_context]];
    });

    return array;
}

@end
