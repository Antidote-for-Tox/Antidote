//
//  ExceptionHandling.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 30/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExceptionHandling : NSObject

+ (void)tryWithBlock:(nonnull void (^)())tryBlock catch:(nonnull void (^)(NSException *__nonnull exception))catchBlock;

@end
