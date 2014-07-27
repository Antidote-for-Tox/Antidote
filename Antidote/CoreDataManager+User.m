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

+ (CDUser *)getOrInsertUserWithPredicate:(NSPredicate *)predicate
                             configBlock:(void (^)(CDUser *theUser))configBlock
{
    __block CDUser *user;

    dispatch_sync([self private_queue], ^{
        user = [CDUser MR_findFirstWithPredicate:predicate inContext:[self private_context]];

        if (! user) {
            user = [NSEntityDescription insertNewObjectForEntityForName:@"CDUser"
                                                 inManagedObjectContext:[self private_context]];

            if (configBlock) {
                configBlock(user);
            }

            [[self private_context] MR_saveToPersistentStoreAndWait];
        }
    });

    return user;
}

@end
