//
//  NotificationObject.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 27.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

extern CGFloat kNotificationObjectImageSize;

@interface NotificationObject : NSObject <NSCopying>

/**
 * Image on the left of notification.
 */
@property (strong, nonatomic) UIImage *image;

@property (copy, nonatomic) NSString *topText;
@property (copy, nonatomic) NSString *bottomText;

/**
 * Tap handler that will be called on notification tap.
 */
@property (copy, nonatomic) void (^tapHandler)(NotificationObject *object);

/**
 * Identifier that can be used to remove group of notifications from queue.
 */
@property (copy, nonatomic) NSString *groupIdentifier;

/**
 * Custom user info for the notification.
 */
@property (strong, nonatomic) NSDictionary *userInfo;

@end
