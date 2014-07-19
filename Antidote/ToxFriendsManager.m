//
//  ToxFriendsManager.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxFriendsManager.h"
#import "UserInfoManager.h"

NSString *const kToxFriendsManagerUpdateNotification = @"kToxFriendsManagerUpdateNotification";
NSString *const kToxFriendsManagerUpdateKeyInsertedSet = @"kToxFriendsManagerUpdateKeyInsertedSet";

@interface ToxFriendsManager()

@property (strong, nonatomic) NSMutableArray *friends;

@end

@implementation ToxFriendsManager

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.friends = [NSMutableArray new];

        for (NSString *publicKey in [UserInfoManager sharedInstance].uPendingFriendRequests) {
            ToxFriend *f = [ToxFriend friendWithPublicKey:publicKey];

            [self.friends addObject:f];
        }
    }

    return self;
}

#pragma mark -  Public

- (NSUInteger)count
{
    @synchronized(self.friends) {
        return self.friends.count;
    }
}

- (ToxFriend *)friendAtIndex:(NSUInteger)index
{
    @synchronized(self.friends) {
        if (index < self.friends.count) {
            return self.friends[index];
        }

        return nil;
    }
}

#pragma mark -  Private for ToxManager

- (void)private_addFriendRequest:(NSString *)publicKey
{
    if (! publicKey) {
        return;
    }

    ToxFriend *friend = [ToxFriend friendWithPublicKey:publicKey];

    NSArray *pendingRequests = [UserInfoManager sharedInstance].uPendingFriendRequests;

    if ([pendingRequests containsObject:friend.clientId]) {
        // already added this request
        return;
    }

    NSMutableArray *array = [NSMutableArray arrayWithArray:pendingRequests];
    [array addObject:friend.clientId];
    [UserInfoManager sharedInstance].uPendingFriendRequests = [array copy];

    @synchronized(self.friends) {
        [self.friends addObject:friend];

        NSIndexSet *inserted = [NSIndexSet indexSetWithIndex:self.friends.count-1];
        [self sendUpdateNotificationWithInsertedSet:inserted];
    }
}

#pragma mark -  Private

- (void)sendUpdateNotificationWithInsertedSet:(NSIndexSet *)inserted
{
    NSMutableDictionary *userInfo = [NSMutableDictionary new];

    if (inserted) {
        userInfo[kToxFriendsManagerUpdateKeyInsertedSet] = inserted;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kToxFriendsManagerUpdateNotification
                                                            object:nil
                                                          userInfo:[userInfo copy]];
    });
}

@end
