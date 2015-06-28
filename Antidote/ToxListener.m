//
//  ToxListener.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 28.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ToxListener.h"
#import "OCTManager.h"
#import "NotificationManager.h"

@interface ToxListener () <OCTSubmanagerUserDelegate>

@end

@implementation ToxListener

#pragma mark -  Lifecycle

- (instancetype)initWithManager:(OCTManager *)manager
{
    self = [super init];

    if (! self) {
        return nil;
    }

    manager.user.delegate = self;
    [self updateConnectionStatus:manager.user.connectionStatus];

    return self;
}

#pragma mark -  OCTSubmanagerUserDelegate

- (void)OCTSubmanagerUser:(OCTSubmanagerUser *)submanager connectionStatusUpdate:(OCTToxConnectionStatus)connectionStatus
{
    [self updateConnectionStatus:connectionStatus];
}

#pragma mark -  Private

- (void)updateConnectionStatus:(OCTToxConnectionStatus)connectionStatus
{
    if (connectionStatus == OCTToxConnectionStatusNone) {
        [[AppContext sharedContext].notification showConnectingView];
    }
    else {
        [[AppContext sharedContext].notification hideConnectingView];
    }
}

@end
