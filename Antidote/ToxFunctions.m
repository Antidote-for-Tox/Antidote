//
//  ToxFunctions.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 31.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <sodium/crypto_box.h>

#import "ToxFunctions.h"
#import "tox.h"

@implementation ToxFunctions

#pragma mark -  Public

+ (uint8_t *)hexStringToBin:(NSString *)string
{
    // byte is represented by exactly 2 hex digits, so lenth of binary string
    // is half of that of the hex one. only hex string with even length
    // valid. the more proper implementation would be to check if strlen(hex_string)
    // is odd and return error code if it is. we assume strlen is even. if it's not
    // then the last byte just won't be written in 'ret'.

    char *hex_string = (char *)string.UTF8String;
    size_t i, len = strlen(hex_string) / 2;
    uint8_t *ret = malloc(len);
    char *pos = hex_string;

    for (i = 0; i < len; ++i, pos += 2)
        sscanf(pos, "%2hhx", &ret[i]);

    return ret;
}

+ (NSString *)addressToString:(uint8_t *)address
{
    return [self binToHexString:address length:TOX_FRIEND_ADDRESS_SIZE];
}

+ (NSString *)clientIdToString:(uint8_t *)clientId
{
    return [self binToHexString:clientId length:TOX_CLIENT_ID_SIZE];
}

+ (NSString *)publicKeyToString:(uint8_t *)publicKey
{
    return [self binToHexString:publicKey length:crypto_box_PUBLICKEYBYTES];
}

#pragma mark -  Private

+ (NSString *)binToHexString:(uint8_t *)bin length:(NSUInteger)length
{
    NSMutableString *string = [NSMutableString stringWithCapacity:length * 2];

    for (NSUInteger idx = 0; idx < length; ++idx) {
        [string appendFormat:@"%02X", bin[idx]];
    }

    return [string copy];
}

@end
