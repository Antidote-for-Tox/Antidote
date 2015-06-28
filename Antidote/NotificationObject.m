//
//  NotificationObject.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 27.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "NotificationObject.h"

@implementation NotificationObject

#pragma mark -  NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    NotificationObject *object = [[[self class] allocWithZone:zone] init];

    object.image = self.image;
    object.topText = self.topText;
    object.bottomText = self.bottomText;
    object.tapHandler = self.tapHandler;
    object.userInfo = self.userInfo;

    return object;
}

@end
