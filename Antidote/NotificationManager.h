//
//  NotificationManager.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 27.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NotificationObject;

/**
 * NotificationManager is responsible for showing different types of notifications,
 * connection status, etc.
 */
@interface NotificationManager : NSObject

/**
 * Enqueues notification to be shown in notification view.
 */
- (void)addNotificationToQueue:(NotificationObject *)notification;

/**
 * Shows/hides connecting view from under navigation.
 */
- (void)showConnectingView;
- (void)hideConnectingView;

@end
