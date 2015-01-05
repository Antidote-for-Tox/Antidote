//
//  UserInfoManager.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoManager : NSObject

// array with ToxFriendRequest's NSDictionaries
@property (strong, nonatomic) NSArray *uPendingFriendRequests;

@property (strong, nonatomic) NSNumber *uCurrentColorscheme;
@property (strong, nonatomic) NSNumber *uFriendsSort;

@property (strong, nonatomic) NSString *uCurrentProfileFileName;

@property (strong, nonatomic) NSNumber *uShowMessageInLocalNotification;

+ (instancetype)sharedInstance;

- (void)createDefaultValuesIfNeeded;

@end
