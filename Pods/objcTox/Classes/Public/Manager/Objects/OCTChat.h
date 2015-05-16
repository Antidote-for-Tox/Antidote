//
//  OCTChat.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 25.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OCTMessageAbstract.h"

@interface OCTChat : NSObject

/**
 * Unique identifier of a chat.
 */
@property (copy, nonatomic, readonly) NSString *uniqueIdentifier;

/**
 * Array with OCTFriends that participate in this chat.
 */
@property (strong, nonatomic, readonly) NSArray *friends;

/**
 * The latest message that was send or received.
 */
@property (strong, nonatomic, readonly) OCTMessageAbstract *lastMessage;

/**
 * This property can be used for storing entered text that wasn't send yet.
 * It is saved automatically and is persistant between relaunches.
 */
@property (strong, nonatomic) NSString *enteredText;

/**
 * This property stores last date when chat was read.
 * `hasUnreadMessages` method use lastReadDate to determine if there are unread messages.
 * It is saved automatically and is persistant between relaunches.
 */
@property (strong, nonatomic) NSDate *lastReadDate;

/**
 * Sets lastReadDate to current date.
 */
- (void)updateLastReadDateToNow;

/**
 * If there are unread messages in chat YES is returned. All messages that have date later than lastReadDate
 * are considered as unread.
 *
 * Please note that you have to set lastReadDate to make this method work.
 *
 * @return YES if there are unread messages, NO otherwise.
 */
- (BOOL)hasUnreadMessages;

@end
