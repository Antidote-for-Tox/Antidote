//
//  OCTArray.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 02.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OCTArray;
@protocol OCTArrayDelegate <NSObject>
/**
 * This method is called after array was updated.
 *
 * Not that currently there is no way to see updated diff. This will be implemented later.
 */
- (void)OCTArrayWasUpdated:(OCTArray *)array;
@end

/**
 * OCTArray is auto-updating container type.
 *
 * Unlike an NSArray, OCTArray hold a single type, specified by the objectClassName property.
 */
@interface OCTArray : NSObject

/**
 * Delegate of array.
 */
@property (weak, nonatomic) id<OCTArrayDelegate> delegate;

/**
 * Number of objects in array.
 */
@property (assign, nonatomic, readonly) NSUInteger count;

/**
 * The class name of objects containerd in array.
 */
@property (copy, nonatomic, readonly) NSString *objectClassName;

/**
 * Returns the first object in array. Returns nil if called on empty array.
 *
 * @return The first object in array.
 */
- (NSObject *)firstObject;

/**
 * Returns the last object in array. Returns nil if called on empty array.
 *
 * @return The last object in array.
 */
- (NSObject *)lastObject;

/**
 * Returns object at specified index.
 *
 * @param index Index of object to return.
 *
 * @return Object at specified index.
 */
- (NSObject *)objectAtIndex:(NSUInteger)index;

/**
 * Get a sorted OCTArray from existing sorted by NSArray of OCTSortDescriptor's.
 *
 * @param descriptors Array with OCTSortDescriptor's
 *
 * @return OCTArray with sorted object.
 */
- (OCTArray *)sortedObjectsUsingDescriptors:(NSArray *)descriptors;

/**
 * Executes a given block using each object in the array, starting with the
 * first object and continuing through the array to the last object.
 *
 * @param block Block to execute. You can set `stop` argument to YES to stop enumeration.
 */
- (void)enumerateObjectsUsingBlock:(void (^)(NSObject *obj, NSUInteger idx, BOOL *stop))block;

@end
