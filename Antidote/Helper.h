//
//  Helper.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 31.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ToxFriend.h"
#import "StatusCircleView.h"

@interface Helper : NSObject

+ (StatusCircleStatus)toxFriendStatusToCircleStatus:(ToxFriendStatus)toxFriendStatus;

@end
