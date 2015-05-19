//
//  OCTFriend.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 10.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTFriend.h"

@interface OCTFriend()

@property (assign, nonatomic, readwrite) OCTToxFriendNumber friendNumber;
@property (copy, nonatomic, readwrite) NSString *publicKey;
@property (copy, nonatomic, readwrite) NSString *name;
@property (copy, nonatomic, readwrite) NSString *statusMessage;
@property (assign, nonatomic, readwrite) OCTToxUserStatus status;
@property (assign, nonatomic, readwrite) OCTToxConnectionStatus connectionStatus;
@property (strong, nonatomic, readwrite) NSDate *lastSeenOnline;
@property (assign, nonatomic, readwrite) BOOL isTyping;

@end

@implementation OCTFriend

@end
