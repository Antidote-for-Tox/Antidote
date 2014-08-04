//
//  ToxFunctions.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 31.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToxFunctions : NSObject

// You are responsible for freeing the return value!
+ (uint8_t *)hexStringToBin:(NSString *)string;

+ (BOOL)isAddressString:(NSString *)string;

+ (NSString *)addressToString:(uint8_t *)address;
+ (NSString *)clientIdToString:(uint8_t *)clientId;
+ (NSString *)publicKeyToString:(uint8_t *)publicKey;

@end
