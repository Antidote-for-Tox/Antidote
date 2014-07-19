//
//  ToxManager.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 18.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToxManager : NSObject

+ (instancetype)sharedInstance;

- (void)bootstrapWithAddress:(NSString *)address port:(NSUInteger)port publicKey:(NSString *)publicKey;

- (NSString *)toxId;

@end
