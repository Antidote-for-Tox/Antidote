//
//  ExceptionHandling.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 30/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

#import "ExceptionHandling.h"

@implementation ExceptionHandling

+ (void)tryWithBlock:(nonnull void (^)())tryBlock catch:(nonnull void (^)(NSException *exception))catchBlock
{
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        catchBlock(exception);
    }
}

@end
