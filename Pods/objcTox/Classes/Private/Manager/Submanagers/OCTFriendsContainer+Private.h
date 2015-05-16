//
//  OCTFriendsContainer+Private.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 16.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTFriendsContainer.h"

#import "OCTSettingsStorageProtocol.h"

@protocol OCTFriendsContainerDataSource <NSObject>
- (id<OCTSettingsStorageProtocol>)friendsContainerGetSettingsStorage;
@end

@interface OCTFriendsContainer (Private)

@property (weak, nonatomic) id<OCTFriendsContainerDataSource> dataSource;

- (instancetype)initWithFriendsArray:(NSArray *)friends;

- (void)configure;

- (void)addFriend:(OCTFriend *)friend;
- (void)updateFriendWithFriendNumber:(OCTToxFriendNumber)friendNumber
                         updateBlock:(void (^)(OCTFriend *friendToUpdate))updateBlock;
- (void)removeFriend:(OCTFriend *)friend;

@end
