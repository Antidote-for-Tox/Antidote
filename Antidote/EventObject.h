//
//  EventObject.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 03.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, EventObjectType) {
    EventObjectTypeChatMessage,
    EventObjectTypeFriendRequest,
};

@interface EventObject : NSObject

@property (assign, nonatomic, readonly) EventObjectType type;
@property (strong, nonatomic, readonly) UIImage *image;

/**
 * object depends on type. For:
 * - EventObjectTypeChatMessage   - CDMessage
 * - EventObjectTypeFriendRequest - ToxFriendRequest
 */
@property (strong, nonatomic, readonly) id object;

+ (EventObject *)objectWithType:(EventObjectType)type image:(UIImage *)image object:(id)object;

@end
