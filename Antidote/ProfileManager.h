//
//  ProfileManager.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 07.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OCTManager.h"

/**
 * Notification send when numberOfUnreadChats gets update
 */
extern NSString *const kProfileManagerNotificationUpdateNumberOfUnreadChats;


@interface ProfileManager : NSObject

/**
 * Tox manager for active profile.
 */
@property (strong, nonatomic, readonly) OCTManager *toxManager;

/**
 * Number of unread chats for active profile.
 */
@property (assign, nonatomic, readonly) NSUInteger numberOfUnreadChats;

/**
 * Name of current profile. Is unique.
 */
@property (strong, nonatomic, readonly) NSString *currentProfileName;

/**
 * Sorted array with all profile names.
 */
@property (strong, nonatomic, readonly) NSArray *allProfiles;


/**
 * Switches to profile with given name. If profile does not exist, creates it.
 */
- (void)switchToProfileWithName:(NSString *)name;

/**
 * Creates profile with given tox save file and name.
 *
 * In case if given name is already taken, create a new one with numeric suffix.
 */
- (void)createProfileWithToxSave:(NSURL *)toxSaveURL name:(NSString *)name;

/**
 * Removes profile with given name.
 */
- (void)deleteProfileWithName:(NSString *)name;

/**
 * Return YES if renamed successfully, NO if name if already taken.
 */
- (BOOL)renameProfileWithName:(NSString *)name toName:(NSString *)toName;

/**
 * Return NSURL path with profile save file.
 */
- (NSURL *)exportProfileWithName:(NSString *)name;

@end
