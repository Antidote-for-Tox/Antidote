//
//  OCTDefaultSettingsStorage.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 07.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OCTSettingsStorageProtocol.h"

/**
 * Default storage for settings. It creates NSDictionary with all saved objects and stores it
 * in the NSUserDefaults at a certain key.
 */
@interface OCTDefaultSettingsStorage : NSObject <OCTSettingsStorageProtocol>

@property (strong, nonatomic, readonly) NSString *userDefaultsKey;

/**
 * Creates new OCTDefaultSettingsStorage instance.
 *
 * @param userDefaultsKey Key that would be used to store/get NSDictionary with saved object.
 *
 * @return Initialized OCTDefaultSettingsStorage object, or nil if userDefaultsKey is nil.
 */
- (instancetype)initWithUserDefaultsKey:(NSString *)userDefaultsKey;

@end
