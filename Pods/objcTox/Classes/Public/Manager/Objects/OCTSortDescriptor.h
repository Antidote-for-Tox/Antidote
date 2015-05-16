//
//  OCTSortDescriptor.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 02.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * An OCTSortDescriptor stores a property name and a sort order for use with
 * sortedObjectsUsingDescriptors:. It is similar to NSSortDescriptor, but
 * supports only the subset of functionality.
 */
@interface OCTSortDescriptor : NSObject

/**
 * The name of the property which this sort descriptor orders results by.
 */
@property (strong, nonatomic, readonly) NSString *property;

/**
 * Whether this descriptor sorts in ascending or descending order.
 */
@property (assign, nonatomic, readonly) BOOL ascending;

+ (instancetype)sortDescriptorWithProperty:(NSString *)property ascending:(BOOL)ascending;

@end
