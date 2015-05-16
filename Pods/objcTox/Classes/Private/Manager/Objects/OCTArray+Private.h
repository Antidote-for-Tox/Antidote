//
//  OCTArray+Private.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 02.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Realm/Realm.h>
#import "OCTArray.h"
#import "OCTConverterProtocol.h"

@interface OCTArray (Private)

- (instancetype)initWithRLMResults:(RLMResults *)results converter:(id<OCTConverterProtocol>)converter;

@end
