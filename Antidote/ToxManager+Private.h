//
//  ToxManager+Private.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 15.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxManager.h"

@interface ToxManager()
{
    void *kIsOnToxManagerQueue;
}

@property (assign, nonatomic, readonly) Tox *tox;

@property (strong, nonatomic, readonly) dispatch_queue_t queue;

@property (strong, nonatomic) dispatch_source_t timer;
@property (assign, nonatomic) uint32_t timerMillisecondsUpdateInterval;

@property (assign, nonatomic) BOOL isConnected;

@property (strong, nonatomic) ToxFriendsContainer *friendsContainer;

- (void)qSaveTox;
- (NSString *)qClientId;

@end

