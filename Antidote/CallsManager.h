//
//  CallsManager.h
//  Antidote
//
//  Created by Chuong Vu on 7/13/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OCTChat;
@class OCTCall;

@interface CallsManager : NSObject

/**
 * Make a call.
 * @param chat The chat for which to make a call
 */
- (void)callToChat:(OCTChat *)chat enableAudio:(BOOL)audio enableVideo:(BOOL)video;

/**
 * Handle an incoming call.
 * Use this to notify the call manager of an incoming call.
 */
- (void)handleIncomingCall:(OCTCall *)call;

@end
