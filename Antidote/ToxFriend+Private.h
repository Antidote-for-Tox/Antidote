//
//  ToxFriend+Private.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 02.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxFriend.h"

@interface ToxFriend ()

@property (assign, nonatomic, readwrite) int32_t id;
@property (strong, nonatomic, readwrite) NSString *clientId;
@property (strong, nonatomic, readwrite) NSString *realName;
@property (strong, nonatomic, readwrite) NSString *nickname;
@property (strong, nonatomic, readwrite) NSString *statusMessage;
@property (strong, nonatomic, readwrite) NSDate *lastSeenOnline;
@property (assign, nonatomic, readwrite) ToxFriendStatus status;
@property (assign, nonatomic, readwrite) BOOL isTyping;

@end
