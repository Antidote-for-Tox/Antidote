//
//  OCTSortDescriptor.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 02.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTSortDescriptor.h"

@interface OCTSortDescriptor()

@property (strong, nonatomic, readwrite) NSString *property;
@property (assign, nonatomic, readwrite) BOOL ascending;

@end

@implementation OCTSortDescriptor

+ (instancetype)sortDescriptorWithProperty:(NSString *)property ascending:(BOOL)ascending
{
    NSParameterAssert(property);

    OCTSortDescriptor *descriptor = [OCTSortDescriptor new];
    descriptor.property = property;
    descriptor.ascending = ascending;

    return descriptor;
}

@end
