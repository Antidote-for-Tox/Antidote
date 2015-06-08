//
//  Helper.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 08.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "Helper.h"
#import "OCTToxConstants.h"

@implementation Helper

#pragma mark -  Public

+ (BOOL)isAddressString:(NSString *)string
{
    if (string.length != kOCTToxAddressLength) {
        return NO;
    }

    NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefABCDEF"];

    NSArray *components = [string componentsSeparatedByCharactersInSet:validChars];

    NSString *leftChars = [components componentsJoinedByString:@""];

    return (leftChars.length == 0);
}

+ (StatusCircleStatus)circleStatusFromFriend:(OCTFriend *)friend
{
    if (friend.connectionStatus == OCTToxConnectionStatusNone) {
        return StatusCircleStatusOffline;
    }

    switch(friend.status) {
        case OCTToxUserStatusNone:
            return StatusCircleStatusOnline;
        case OCTToxUserStatusAway:
            return StatusCircleStatusAway;
        case OCTToxUserStatusBusy:
            return StatusCircleStatusBusy;
    }
}

@end
