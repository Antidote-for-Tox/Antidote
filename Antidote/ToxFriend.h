//
//  ToxFriend.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ToxFriendStatus) {
    ToxFriendStatusOffline,
    ToxFriendStatusOnline,
    ToxFriendStatusAway,
    ToxFriendStatusBusy,
};

@interface ToxFriend : NSObject

@property (assign, nonatomic, readonly) int32_t id;
@property (strong, nonatomic, readonly) NSString *clientId;
@property (strong, nonatomic, readonly) NSString *realName;
@property (strong, nonatomic, readonly) NSString *associatedName;
@property (strong, nonatomic, readonly) NSString *statusMessage;
@property (assign, nonatomic, readonly) ToxFriendStatus status;

- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

@end
