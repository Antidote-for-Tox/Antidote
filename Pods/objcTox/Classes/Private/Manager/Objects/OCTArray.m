//
//  OCTArray.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 02.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTArray.h"
#import "OCTArray+Private.h"
#import "OCTDBManager.h"

@interface OCTArray()

/**
 * For now there is no RLMResults update notification. When it will be implemented it would
 * be nice to add that feature for OCTArray.
 *
 * See https://github.com/realm/realm-cocoa/issues/687
 */
@property (strong, nonatomic) RLMResults *results;
@property (strong, nonatomic) id<OCTConverterProtocol> converter;

@end

@implementation OCTArray

#pragma mark -  Lifecycle

- (instancetype)initWithRLMResults:(RLMResults *)results converter:(id<OCTConverterProtocol>)converter
{
    NSParameterAssert(results);
    NSParameterAssert(converter);

    self = [super init];

    if (! self) {
        return nil;
    }

    self.results = results;
    self.converter = converter;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNotification:)
                                                 name:kOCTDBManagerUpdateNotification
                                               object:nil];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -  Properties

- (NSUInteger)count
{
    return self.results.count;
}

- (NSString *)objectClassName
{
    return self.converter.objectClassName;
}

#pragma mark -  Public

- (NSObject *)firstObject
{
    RLMObject *object = [self.results firstObject];

    return object ? [self.converter objectFromRLMObject:object] : nil;
}

- (NSObject *)lastObject
{
    RLMObject *object = [self.results lastObject];

    return object ? [self.converter objectFromRLMObject:object] : nil;
}

- (NSObject *)objectAtIndex:(NSUInteger)index
{
    RLMObject *object = [self.results objectAtIndex:index];

    return object ? [self.converter objectFromRLMObject:object] : nil;
}

- (OCTArray *)sortedObjectsUsingDescriptors:(NSArray *)array
{
    NSMutableArray *rlmArray = [NSMutableArray new];
    for (OCTSortDescriptor *descriptor in array) {
        RLMSortDescriptor *rlmDescriptor = [self.converter rlmSortDescriptorFromDescriptor:descriptor];

        if (rlmDescriptor) {
            [rlmArray addObject:rlmDescriptor];
        }
    }

    RLMResults *results = [self.results sortedResultsUsingDescriptors:rlmArray];

    return [[OCTArray alloc] initWithRLMResults:results converter:self.converter];
}

- (void)enumerateObjectsUsingBlock:(void (^)(NSObject *obj, NSUInteger idx, BOOL *stop))block
{
    NSParameterAssert(block);

    BOOL stop = NO;
    for (NSUInteger index = 0; index < self.results.count; index++) {
        RLMObject *rlmObject = [self.results objectAtIndex:index];
        NSObject *object = [self.converter objectFromRLMObject:rlmObject];

        block(object, index, &stop);

        if (stop) {
            break;
        }
    }
}

#pragma mark -  Notifications

- (void)updateNotification:(NSNotification *)notification
{
    Class class = notification.userInfo[kOCTDBManagerObjectClassKey];

    if (! class) {
        return;
    }

    NSString *string = NSStringFromClass(class);

    if (! [string isEqualToString:[self objectClassName]]) {
        return;
    }

    [self.delegate OCTArrayWasUpdated:self];
}

@end
