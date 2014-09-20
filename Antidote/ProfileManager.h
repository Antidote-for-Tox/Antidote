//
//  ProfileManager.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 17.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CDProfile.h"

@interface ProfileManager : NSObject

@property (strong, nonatomic, readonly) CDProfile *currentProfile;

+ (instancetype)sharedInstance;

- (void)configureCurrentProfileAndLoadTox;

- (NSData *)toxDataForCurrentProfile;
- (void)saveToxDataForCurrentProfile:(NSData *)data;

- (void)addNewProfileWithName:(NSString *)name;
- (void)addNewProfileWithName:(NSString *)name fromURL:(NSURL *)url removeAfterAdding:(BOOL)removeAfterAdding;
- (void)switchToProfile:(CDProfile *)profile;
- (void)renameProfile:(CDProfile *)profile to:(NSString *)name;
- (void)deleteProfile:(CDProfile *)profile;
- (NSURL *)toxDataURLForProfile:(CDProfile *)profile;

- (NSString *)pathInFilesForCurrentProfileFromFileName:(NSString *)fileName temporary:(BOOL)temporary;
- (NSString *)fileDirectoryPathForCurrentProfileIsTemporary:(BOOL)temporary;

@end
