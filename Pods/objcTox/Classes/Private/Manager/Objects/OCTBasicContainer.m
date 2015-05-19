//
//  OCTBasicContainer.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 16.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTBasicContainer.h"
#import "OCTManagerConstants.h"

@interface OCTBasicContainer()

@property (strong, nonatomic) NSMutableArray *array;

@property (copy, nonatomic) NSComparator comparator;

@property (copy, nonatomic) NSString *updateNotificationName;


@end

@implementation OCTBasicContainer

#pragma mark -  Lifecycle

- (instancetype)initWithObjects:(NSArray *)objects updateNotificationName:(NSString *)updateNotificationName
{
    self = [super init];

    if (! self) {
        return nil;
    }

    self.array = [NSMutableArray arrayWithArray:objects];
    self.updateNotificationName = updateNotificationName;

    return self;
}

#pragma mark -  Public

- (void)setComparatorForCurrentSort:(NSComparator)comparator sendNotification:(BOOL)sendNotification
{
    self.comparator = comparator;

    if (! comparator) {
        return;
    }

    @synchronized(self.array) {
        if (self.array.count <= 1) {
            return;
        }

        [self.array sortUsingComparator:self.comparator];

        if (sendNotification) {
            NSRange range = NSMakeRange(0, self.array.count);
            [self sendUpdateNotificationWithInsertedSet:nil
                                             removedSet:nil
                                             updatedSet:[NSIndexSet indexSetWithIndexesInRange:range]];
        }
    }
}

- (NSUInteger)count
{
    @synchronized(self.array) {
        return self.array.count;
    }
}

- (id)objectAtIndex:(NSUInteger)index
{
    @synchronized(self.array) {
        if (index < self.array.count) {
            return self.array[index];
        }

        return nil;
    }
}

- (void)addObject:(id)object
{
    NSParameterAssert(object);

    if (! object) {
        return;
    }

    @synchronized(self.array) {
        NSUInteger index = [self.array indexOfObject:object];

        if (index != NSNotFound) {
            NSAssert(NO, @"Cannot add object twice %@", object);
            return;
        }

        if (self.comparator) {
            index = [self.array indexOfObject:object
                                inSortedRange:NSMakeRange(0, self.array.count)
                                      options:NSBinarySearchingInsertionIndex
                              usingComparator:self.comparator];

            [self.array insertObject:object atIndex:index];
        }
        else {
            index = self.array.count;
            [self.array addObject:object];
        }

        [self sendUpdateNotificationWithInsertedSet:[NSIndexSet indexSetWithIndex:index]
                                         removedSet:nil
                                         updatedSet:nil];
    }
}

- (void)removeObject:(id)object
{
    NSParameterAssert(object);

    if (! object) {
        return;
    }

    @synchronized(self.array) {
        NSUInteger index = [self.array indexOfObject:object];

        if (index == NSNotFound) {
            NSAssert(NO, @"Cannot remove object, object not found");
            return;
        }

        [self.array removeObjectAtIndex:index];

        [self sendUpdateNotificationWithInsertedSet:nil
                                         removedSet:[NSIndexSet indexSetWithIndex:index]
                                         updatedSet:nil];
    }
}

- (void)updateObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))testBlock
                    updateBlock:(void (^)(id object))updateBlock
{
    NSParameterAssert(testBlock);
    NSParameterAssert(updateBlock);

    if (! testBlock || ! updateBlock) {
        return;
    }

    @synchronized(self.array) {
        NSUInteger index = NSNotFound;
        index = [self.array indexOfObjectPassingTest:testBlock];

        if (index == NSNotFound) {
            NSAssert(NO, @"Object to update not found");
            return;
        }

        id object = self.array[index];
        updateBlock(object);

        [self.array removeObjectAtIndex:index];

        NSUInteger newIndex;

        if (self.comparator) {
            newIndex = [self.array indexOfObject:object
                                   inSortedRange:NSMakeRange(0, self.array.count)
                                         options:NSBinarySearchingInsertionIndex
                                 usingComparator:self.comparator];
        }
        else {
            newIndex = self.array.count;
        }

        [self.array insertObject:object atIndex:index];

        NSIndexSet *inserted, *removed, *updated;

        if (index == newIndex) {
            updated = [NSIndexSet indexSetWithIndex:index];
        }
        else {
            inserted = [NSIndexSet indexSetWithIndex:newIndex];
            removed = [NSIndexSet indexSetWithIndex:index];
        }

        [self sendUpdateNotificationWithInsertedSet:inserted removedSet:removed updatedSet:updated];
    }
}

#pragma mark -  Private

- (void)sendUpdateNotificationWithInsertedSet:(NSIndexSet *)inserted
                                   removedSet:(NSIndexSet *)removed
                                   updatedSet:(NSIndexSet *)updated
{
    if (! self.updateNotificationName) {
        return;
    }

    NSMutableDictionary *userInfo = [NSMutableDictionary new];

    if (inserted.count) {
        userInfo[kOCTContainerUpdateKeyInsertedSet] = inserted;
    }
    if (removed.count) {
        userInfo[kOCTContainerUpdateKeyRemovedSet] = removed;
    }
    if (updated.count) {
        userInfo[kOCTContainerUpdateKeyUpdatedSet] = updated;
    }

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    if ([NSThread isMainThread]) {
        [center postNotificationName:self.updateNotificationName object:nil userInfo:userInfo];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [center postNotificationName:self.updateNotificationName object:nil userInfo:userInfo];
        });
    }
}

@end
