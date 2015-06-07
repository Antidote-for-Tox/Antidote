//
//  ProfileManager.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 07.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfileManager : NSObject

/**
 * Tox manager for active profile.
 */
@property (strong, nonatomic, readonly) OCTManager *toxManager;

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
 * Removes profile with given name.
 */
- (void)deleteProfileWithName:(NSString *)name;

@end
