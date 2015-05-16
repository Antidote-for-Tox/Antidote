//
//  OCTMessageAbstract+Private.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 24.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTMessageAbstract.h"

@interface OCTMessageAbstract (Private)

@property (strong, nonatomic, readwrite) NSDate *date;
@property (strong, nonatomic, readwrite) OCTFriend *sender;

@end
