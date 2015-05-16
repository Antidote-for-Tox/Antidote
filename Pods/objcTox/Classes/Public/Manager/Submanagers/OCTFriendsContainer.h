//
//  OCTFriendsContainer.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 15.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OCTFriend.h"
#import "OCTManagerConstants.h"

/**
 * On adding/removing/updating friend posts kOCTFriendsContainerUpdateNotification notification.
 */
@interface OCTFriendsContainer : NSObject

/**
 * The sort to be used for friends. Sort is saved in settings and remains same after relaunch.
 *
 * @warning After assigning this property all friends will be resorted, so you'll get different results from methods below.
 */
@property (assign, nonatomic) OCTFriendsSort friendsSort;

/**
 * @return Total number of friends.
 */
- (NSUInteger)friendsCount;

/**
 * Returns friend at specified index.
 *
 * @param index Index to get friend. May be out of bounds, in this case nil will be returned.
 *
 * @return Friend at index. If index is out of bounds nil will be returned.
 */
- (OCTFriend *)friendAtIndex:(NSUInteger)index;

@end
