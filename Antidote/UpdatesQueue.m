//
//  UpdatesQueue.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 28.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "UpdatesQueue.h"

@implementation UpdatesQueueObject
@end

@interface UpdatesQueue()

@property (strong, nonatomic) NSMutableArray *queue;

@end

@implementation UpdatesQueue

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    _queue = [NSMutableArray new];

    return self;
}

#pragma mark -  Public

- (NSArray *)getQueue
{
    return [self.queue copy];
}

- (void)enqueuePath:(NSIndexPath *)path type:(UpdatesQueueObjectType)type
{
    UpdatesQueueObject *object = [UpdatesQueueObject new];
    object.path = path;
    object.type = type;

    [self.queue addObject:object];
}

- (UpdatesQueueObject *)dequeue
{
    if (! self.queue.count) {
        return nil;
    }

    UpdatesQueueObject *object = [self.queue firstObject];
    [self.queue removeObjectAtIndex:0];

    return object;
}

- (void)removeObject:(UpdatesQueueObject *)object
{
    [self.queue removeObject:object];
}

- (void)clear
{
    [self.queue removeAllObjects];
}

@end
