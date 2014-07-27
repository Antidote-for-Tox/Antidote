//
//  CoreDataManager+User.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CoreDataManager+User.h"
#import "CoreData+MagicalRecord.h"

@implementation CoreDataManager (User)

+ (CDUser *)firstUserWithPredicate:(NSPredicate *)predicate
{
    __block CDUser *user;

    dispatch_sync([self private_queue], ^{
        user = [CDUser MR_findFirstWithPredicate:predicate inContext:[self private_context]];
    });

    return user;
}

+ (CDUser *)insertUserWithConfigBlock:(void (^)(CDUser *theUser))configBlock
{
    if (! configBlock) {
        return nil;
    }

    __block CDUser *user;

    dispatch_sync([self private_queue], ^{
        user = [NSEntityDescription insertNewObjectForEntityForName:@"CDUser"
                                             inManagedObjectContext:[self private_context]];

        configBlock(user);

        [[self private_context] MR_saveToPersistentStoreAndWait];
    });

    return user;
}

@end
