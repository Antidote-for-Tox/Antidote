//
//  OCTBasicContainer.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 16.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Basic container that saves it's objects in sorted array. Is threadsafe.
 */
@interface OCTBasicContainer : NSObject

/**
 * @param objects Initial array with objects.
 * @param updateNotification Notification that will be send on array update (on adding, removing or updating object).
 */
- (instancetype)initWithObjects:(NSArray *)objects updateNotificationName:(NSString *)updateNotificationName;

/**
 * Sets comparator, resorts objects and send notification (if flag is set).
 *
 * @param comparator Comparator to be sorted with.
 * @param sendNotification If YES, container will send notification with updates.
 */
- (void)setComparatorForCurrentSort:(NSComparator)comparator sendNotification:(BOOL)sendNotification;

/**
 * @return Total number of objects.
 */
- (NSUInteger)count;

/**
 * Returns object at specified index. If index is out of bounds returns nil.
 */
- (id)objectAtIndex:(NSUInteger)index;

/**
 * Adds object to array. Note that one object can be added only once.
 */
- (void)addObject:(id)object;

/**
 * Remove object. Object must be in array.
 */
- (void)removeObject:(id)object;

/**
 * Remove object. Object must be in array.
 */
- (void)updateObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))testBlock
                    updateBlock:(void (^)(id object))updateBlock;

@end
