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

+ (void)getOrInsertUserWithPredicate:(NSPredicate *)predicate
                         configBlock:(void (^)(CDUser *user))configBlock
                     completionQueue:(dispatch_queue_t)queue
                     completionBlock:(void (^)(CDUser *user))completionBlock
{
    dispatch_async([self private_queue], ^{
        CDUser *user = [CDUser MR_findFirstWithPredicate:predicate inContext:[self private_context]];

        if (! user) {
            user = [NSEntityDescription insertNewObjectForEntityForName:@"CDUser"
                                                 inManagedObjectContext:[self private_context]];

            if (configBlock) {
                configBlock(user);
            }

            [[self private_context] MR_saveToPersistentStoreAndWait];

            DDLogVerbose(@"CoreDataManager+User: inserted user %@", user);
        }

        if (! completionBlock) {
            return;
        }

        [self private_performBlockOnQueueOrMain:queue block:^{
            completionBlock(user);
        }];
    });
}

@end
