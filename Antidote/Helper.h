//
//  Helper.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 08.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StatusCircleView.h"
#import "OCTFriend.h"

@interface Helper : NSObject

+ (BOOL)isAddressString:(NSString *)string;

+ (StatusCircleStatus)circleStatusFromFriend:(OCTFriend *)friend;

@end
