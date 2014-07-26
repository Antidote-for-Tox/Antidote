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

@property (assign, nonatomic) int32_t id;
@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) NSString *realName;
@property (strong, nonatomic) NSString *associatedName;
@property (assign, nonatomic) ToxFriendStatus status;

- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

@end
