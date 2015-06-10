//
//  UserDefaultsManager.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 19.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultsManager : NSObject

// array with ToxFriendRequest's NSDictionaries
@property (strong, nonatomic) NSArray *uPendingFriendRequests;

@property (strong, nonatomic) NSNumber *uCurrentColorscheme;
@property (strong, nonatomic) NSNumber *uFriendsSort;

@property (strong, nonatomic) NSString *uCurrentProfileName;

@property (strong, nonatomic) NSNumber *uShowMessageInLocalNotification;
@property (strong, nonatomic) NSNumber *uIpv6Enabled;
@property (strong, nonatomic) NSNumber *uUDPEnabled;

@end
