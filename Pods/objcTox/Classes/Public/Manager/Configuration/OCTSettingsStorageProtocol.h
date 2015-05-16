//
//  OCTSettingsStorageProtocol.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 07.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OCTSettingsStorageProtocol <NSObject>

@required

/**
 * Sets object to be stored by specified key.
 *
 * @param object Object to be stored. Object _always_ will be only property list object - NSData, NSString, NSNumber, NSDate, NSArray, or NSDictionary.
 * @param key The key with which to associate with object.
 */
- (void)setObject:(id)object forKey:(NSString *)key;

/**
 * Returns stored object associated with key.
 *
 * @param key The key with object was associated.
 *
 * @return Returns stored object, or nil if key was not found.
 */
- (id)objectForKey:(NSString *)key;

@end
