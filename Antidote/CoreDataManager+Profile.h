//
//  CoreDataManager+Profile.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 17.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CoreDataManager.h"
#import "CDProfile.h"

@interface CoreDataManager (Profile)

+ (CDProfile *)syncProfileWithPredicate:(NSPredicate *)predicate;
+ (CDProfile *)syncAddProfileWithConfigBlock:(void (^)(CDProfile *profile))configBlock;

+ (void)addProfileWithConfigBlock:(void (^)(CDProfile *profile))configBlock
                  completionQueue:(dispatch_queue_t)queue
                  completionBlock:(void (^)(CDProfile *profile))completionBlock;

+ (void)fetchedControllerWithDelegate:(id <NSFetchedResultsControllerDelegate>)delegate
                      completionQueue:(dispatch_queue_t)queue
                      completionBlock:(void (^)(NSFetchedResultsController *controller))completionBlock;

+ (void)removeProfileWithAllRelatedCDObjects:(CDProfile *)profile
                             completionQueue:(dispatch_queue_t)queue
                             completionBlock:(void (^)())completionBlock;

@end
