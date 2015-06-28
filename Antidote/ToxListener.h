//
//  ToxListener.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 28.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OCTManager.h"

/**
 * ToxListener subscribes to different OCTManager updates and send notifications,
 * shows connecting status, etc.
 */
@interface ToxListener : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * Inits with manager listen to.
 */
- (instancetype)initWithManager:(OCTManager *)manager;

@end
