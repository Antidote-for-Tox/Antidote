//
//  CoreDataManager.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 26.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CoreDataManager.h"
#import "CoreData+MagicalRecord.h"

@interface CoreDataManager()
{
    void *kIsOnCoreDataManagerQueue;
}

@property (strong, nonatomic) dispatch_queue_t queue;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation CoreDataManager

#pragma mark -  Lifecycle

- (id)init
{
    return nil;
}

- (id)initPrivate
{
    if (self = [super init]) {
        _queue = dispatch_queue_create("CoreDataManager queue", NULL);

        dispatch_sync(_queue, ^{
            _context = [NSManagedObjectContext MR_contextForCurrentThread];
        });

        // The dispatch_queue_set_specific() and dispatch_get_specific() functions take a
        // "void *key" parameter.
        // From the documentation:
        //
        // > Keys are only compared as pointers and are never dereferenced.
        // > Thus, you can use a pointer to a static variable for a specific subsystem or
        // > any other value that allows you to identify the value uniquely.

        // assigning to variable its address, so we can use kIsOnCoreDataManagerQueue
        // instead of &kIsOnCoreDataManagerQueue.
        kIsOnCoreDataManagerQueue = &kIsOnCoreDataManagerQueue;

        void *nonNullUnusedPointer = (__bridge void *)self;

        dispatch_queue_set_specific(_queue, kIsOnCoreDataManagerQueue, nonNullUnusedPointer, NULL);
    }

    return self;
}

+ (instancetype)sharedInstance
{
    static CoreDataManager *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{

        if (! instance) {
            instance = [[CoreDataManager alloc] initPrivate];
        }
    });

    return instance;
}

#pragma mark -  Class methods

+ (dispatch_queue_t)private_queue
{
    return [[self sharedInstance] queue];
}

+ (NSManagedObjectContext *)private_context
{
    NSAssert(dispatch_get_specific(
                ((CoreDataManager *)[self sharedInstance])->kIsOnCoreDataManagerQueue),
                @"Must be on CoreDataManager queue");

    return [[self sharedInstance] context];
}

@end
