//
//  EventObject.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 03.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "EventObject.h"

@implementation EventObject

+ (EventObject *)objectWithType:(EventObjectType)type image:(UIImage *)image object:(id)object
{
    EventObject *o = [EventObject new];

    o->_type = type;
    o->_image = image;
    o->_object = object;

    return o;
}

@end
