//
//  UpdatesQueue.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 28.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UpdatesQueueObjectType) {
    UpdatesQueueObjectTypeInsert,
    UpdatesQueueObjectTypeDelete,
    UpdatesQueueObjectTypeUpdate,
};

@interface UpdatesQueueObject : NSObject

@property (strong, nonatomic) NSIndexPath *path;
@property (assign, nonatomic) UpdatesQueueObjectType type;

@end

/**
 * Queue for RBQFetchedResultsController updates
 */
@interface UpdatesQueue : NSObject

- (NSArray *)getQueue;

- (void)enqueuePath:(NSIndexPath *)path type:(UpdatesQueueObjectType)type;

/**
 * If there is nothing to dequeue returns nil
 */
- (UpdatesQueueObject *)dequeue;

- (void)removeObject:(UpdatesQueueObject *)object;

- (void)clear;

@end
