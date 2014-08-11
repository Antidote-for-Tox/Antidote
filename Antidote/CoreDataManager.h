//
//  CoreDataManager.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 26.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataManager : NSObject

+ (void)editCDObjectWithBlock:(void (^)())block
              completionQueue:(dispatch_queue_t)queue
              completionBlock:(void (^)())completionBlock;

@end

/**
 * Private methods for categories.
 */
@interface CoreDataManager(Private)

+ (dispatch_queue_t)private_queue;
+ (NSManagedObjectContext *)private_context;
+ (void)private_performBlockOnQueueOrMain:(dispatch_queue_t)queue block:(void (^)())block;

@end
