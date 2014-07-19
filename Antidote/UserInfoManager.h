//
//  UserInfoManager.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoManager : NSObject

@property (strong, nonatomic) NSData *uToxData;

// array with NSStrings - clientIds
@property (strong, nonatomic) NSArray *uPendingFriendRequests;

+ (instancetype)sharedInstance;

@end
