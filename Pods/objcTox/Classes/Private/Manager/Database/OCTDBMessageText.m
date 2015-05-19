//
//  OCTDBMessageText.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 24.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTDBMessageText.h"
#import "OCTMessageText+Private.h"

@implementation OCTDBMessageText

- (instancetype)initWithMessageText:(OCTMessageText *)message
{
    self = [super init];

    if (! self) {
        return nil;
    }

    self.text = message.text;
    self.isDelivered = message.isDelivered;
    self.type = message.type;

    return self;
}

@end
