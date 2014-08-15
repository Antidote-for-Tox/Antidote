//
//  Helper.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 31.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "Helper.h"
#import "ToxManager.h"
#import "CDUser.h"

@implementation Helper

+ (StatusCircleStatus)toxFriendStatusToCircleStatus:(ToxFriendStatus)toxFriendStatus
{
    if (toxFriendStatus == ToxFriendStatusOffline) {
        return StatusCircleStatusOffline;
    }
    else if (toxFriendStatus == ToxFriendStatusOnline) {
        return StatusCircleStatusOnline;
    }
    else if (toxFriendStatus == ToxFriendStatusAway) {
        return StatusCircleStatusAway;
    }
    else if (toxFriendStatus == ToxFriendStatusBusy) {
        return StatusCircleStatusBusy;
    }

    return StatusCircleStatusOffline;
}

+ (BOOL)isOutgoingMessage:(CDMessage *)message
{
    return [message.user.clientId isEqual:[ToxManager sharedInstance].clientId];
}

@end
