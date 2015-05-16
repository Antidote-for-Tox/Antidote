//
//  OCTManagerConfiguration.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 08.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OCTSettingsStorageProtocol.h"
#import "OCTFileStorageProtocol.h"
#import "OCTToxOptions.h"

/**
 * Configuration for OCTManager.
 */
@interface OCTManagerConfiguration : NSObject <NSCopying>

/**
 * Settings storage to be used.
 *
 * By default OCTDefaultSettingsStorage will be used.
 */
@property (strong, nonatomic) id<OCTSettingsStorageProtocol> settingsStorage;

/**
 * File storage to be used.
 *
 * By default OCTDefaultFileStorage will be used.
 */
@property (strong, nonatomic) id<OCTFileStorageProtocol> fileStorage;

/**
 * Options for tox to use.
 */
@property (strong, nonatomic) OCTToxOptions *options;

/**
 * This is default configuration for manager. Parameters are follows
 *
 * - settings are stored in NSDictionary in NSUserDefaults for "me.dvor.objcTox.settings" key;
 *
 * - tox save file is stored at "{app document directory}/me.dvor.objcTox/save.tox"
 * - downloaded files are stored at "{app document directory}/me.dvor.objcTox/downloads"
 * - uploaded files are stored at "{app document directory}/me.dvor.objcTox/uploads"
 * - avatars are stored at "{app document directory}/me.dvor.objcTox/avatars"
 * - temporary files are stored at NSTemporaryDirectory()
 *
 * - IPv6 support enabled
 * - UDP support enabled
 * - No proxy is used.
 *
 * @return Default configuration for OCTManager.
 *
 * @warning On mobile devices you may want to turn off UDP support to increase battery life.
 */
+ (instancetype)defaultConfiguration;

@end
