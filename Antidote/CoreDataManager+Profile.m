//
//  CoreDataManager+Profile.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 17.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CoreDataManager+Profile.h"
#import "CoreData+MagicalRecord.h"

@implementation CoreDataManager (Profile)

+ (CDProfile *)syncProfileWithPredicate:(NSPredicate *)predicate;
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    return [CDProfile MR_findFirstWithPredicate:predicate inContext:context];
}

+ (CDProfile *)syncAddProfileWithConfigBlock:(void (^)(CDProfile *profile))configBlock
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];

    CDProfile *profile = [NSEntityDescription insertNewObjectForEntityForName:@"CDProfile"
                                                       inManagedObjectContext:context];

    if (configBlock) {
        configBlock(profile);
    }

    [context MR_saveToPersistentStoreAndWait];

    DDLogVerbose(@"CoreDataManager+Profile: created profile %@", profile);

    return profile;
}

+ (void)addProfileWithConfigBlock:(void (^)(CDProfile *profile))configBlock
                  completionQueue:(dispatch_queue_t)queue
                  completionBlock:(void (^)(CDProfile *profile))completionBlock
{
    dispatch_async([self private_queue], ^{
        CDProfile *profile = [NSEntityDescription insertNewObjectForEntityForName:@"CDProfile"
                                                           inManagedObjectContext:[self private_context]];

        if (configBlock) {
            configBlock(profile);
        }

        [[self private_context] MR_saveToPersistentStoreAndWait];

        DDLogVerbose(@"CoreDataManager+Profile: created profile %@", profile);

        if (! completionBlock) {
            return;
        }

        [self private_performBlockOnQueueOrMain:queue block:^{
            completionBlock(profile);
        }];
    });
}

+ (void)fetchedControllerWithDelegate:(id <NSFetchedResultsControllerDelegate>)delegate
                      completionQueue:(dispatch_queue_t)queue
                      completionBlock:(void (^)(NSFetchedResultsController *controller))completionBlock;
{
    if (! completionBlock) {
        return;
    }

    dispatch_async([self private_queue], ^{
        NSFetchedResultsController *controller = [CDProfile MR_fetchAllSortedBy:@"name"
                                                                      ascending:NO
                                                                  withPredicate:nil
                                                                        groupBy:nil
                                                                       delegate:delegate
                                                                      inContext:[self private_context]];

        [self private_performBlockOnQueueOrMain:queue block:^{
            completionBlock(controller);
        }];
    });
}

@end
