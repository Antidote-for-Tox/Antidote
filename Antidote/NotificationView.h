//
//  NotificationView.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 27.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NotificationObject.h"

extern const CGFloat kNotificationViewHeight;

@interface NotificationView : UIView

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithObject:(NotificationObject *)object;

@end
