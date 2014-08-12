//
//  ToxFriend.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ToxFriendStatus) {
    ToxFriendStatusOnline = 0,
    ToxFriendStatusAway,
    ToxFriendStatusBusy,
    ToxFriendStatusOffline,
};

@interface ToxFriend : NSObject

@property (assign, nonatomic, readonly) int32_t id;
@property (strong, nonatomic, readonly) NSString *clientId;
@property (strong, nonatomic, readonly) NSString *realName;
@property (strong, nonatomic, readonly) NSString *associatedName;
@property (strong, nonatomic, readonly) NSString *statusMessage;
@property (strong, nonatomic, readonly) NSDate *lastSeenOnline;
@property (assign, nonatomic, readonly) ToxFriendStatus status;
@property (assign, nonatomic, readonly) BOOL isTyping;

- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

- (NSString *)nameToShow;

@end
