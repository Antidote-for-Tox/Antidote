//
//  OCTFriendsContainer.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 15.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTFriendsContainer.h"
#import "OCTFriendsContainer+Private.h"
#import "OCTBasicContainer.h"

static NSString *const kSortStorageKey = @"OCTFriendsContainer.sortStorageKey";

@interface OCTFriendsContainer()

@property (weak, nonatomic) id<OCTFriendsContainerDataSource> dataSource;

@property (strong, nonatomic) OCTBasicContainer *container;

@property (assign, nonatomic) dispatch_once_t configureOnceToken;

@end

@implementation OCTFriendsContainer

#pragma mark -  Lifecycle

- (instancetype)initWithFriendsArray:(NSArray *)friends
{
    self = [super init];

    if (! self) {
        return nil;
    }

    self.container = [[OCTBasicContainer alloc] initWithObjects:friends
                                         updateNotificationName:kOCTFriendsContainerUpdateNotification];

    return self;
}

#pragma mark -  Public

- (void)setFriendsSort:(OCTFriendsSort)sort
{
    _friendsSort = sort;
    [self.container setComparatorForCurrentSort:[self comparatorForCurrentSort] sendNotification:YES];
}

- (NSUInteger)friendsCount
{
    return [self.container count];
}

- (OCTFriend *)friendAtIndex:(NSUInteger)index
{
    return [self.container objectAtIndex:index];
}

#pragma mark -  Private category

- (void)configure
{
    dispatch_once(&_configureOnceToken, ^{
        NSNumber *sort = [self.dataSource.friendsContainerGetSettingsStorage objectForKey:kSortStorageKey];
        self.friendsSort = [sort unsignedIntegerValue];
        [self.container setComparatorForCurrentSort:[self comparatorForCurrentSort] sendNotification:NO];
    });
}

- (void)addFriend:(OCTFriend *)friend
{
    [self.container addObject:friend];
}

- (void)updateFriendWithFriendNumber:(OCTToxFriendNumber)friendNumber
                         updateBlock:(void (^)(OCTFriend *friendToUpdate))updateBlock
{
    [self.container updateObjectPassingTest:^BOOL (OCTFriend *friend, NSUInteger idx, BOOL *stop) {
        return (friend.friendNumber == friendNumber);

    } updateBlock:updateBlock];
}

- (void)removeFriend:(OCTFriend *)friend
{
    [self.container removeObject:friend];
}

#pragma mark -  Private

- (NSComparator)comparatorForCurrentSort
{
    NSComparator nameComparator = ^NSComparisonResult (OCTFriend *first, OCTFriend *second) {
        if (first.name && second.name) {
            return [first.name compare:second.name];
        }

        if (first.name) {
            return NSOrderedDescending;
        }
        if (second.name) {
            return NSOrderedAscending;
        }

        return [first.publicKey compare:second.publicKey];
    };

    switch(self.friendsSort) {
        case OCTFriendsSortByName:
            return nameComparator;

        case OCTFriendsSortByStatus:
            return ^NSComparisonResult (OCTFriend *first, OCTFriend *second) {
                if (first.connectionStatus  == OCTToxConnectionStatusNone &&
                    second.connectionStatus == OCTToxConnectionStatusNone)
                {
                    return nameComparator(first, second);
                }

                if (first.connectionStatus  == OCTToxConnectionStatusNone) {
                    return NSOrderedDescending;
                }
                if (second.connectionStatus  == OCTToxConnectionStatusNone) {
                    return NSOrderedAscending;
                }

                if (first.status == second.status) {
                    return nameComparator(first, second);
                }

                return (first.status > second.status) ? NSOrderedDescending : NSOrderedAscending;
            };
    }
}

@end
