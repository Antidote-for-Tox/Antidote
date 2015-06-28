//
//  NotificationObject.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 27.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@property (strong, nonatomic) NSDictionary *userInfo;

@end
