//
//  NSIndexSet+Utilities.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 26.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "NSIndexSet+Utilities.h"

@implementation NSIndexSet (Utilities)

- (NSArray *)arrayWithIndexPaths
{
    NSMutableArray *array = [NSMutableArray new];

    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:idx inSection:0];
        [array addObject:path];
    }];

    return [array copy];
}

@end
