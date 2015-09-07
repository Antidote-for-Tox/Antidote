//
//  ProfileManager.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 07.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OCTManagerConfiguration;

@interface ProfileManager : NSObject

/**
 * Sorted array with all profile names.
 */
@property (strong, nonatomic, readonly) NSArray *allProfiles;

- (BOOL)createProfileWithName:(NSString *)name error:(NSError **)error;

/**
 * Removes profile with given name.
 */
- (BOOL)deleteProfileWithName:(NSString *)name error:(NSError **)error;

/**
 * Return YES if renamed successfully, NO if name if already taken.
 */
- (BOOL)renameProfileWithName:(NSString *)name toName:(NSString *)toName error:(NSError **)error;

/**
 * Returns configuration for profile with given name. Returns nil if profile does not exist.
 */
- (OCTManagerConfiguration *)configurationForProfileWithName:(NSString *)name;

@end
