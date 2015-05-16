//
//  OCTFileStorageProtocol.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 08.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OCTFileStorageProtocol <NSObject>

@required

/**
 * Returns path where tox save data will be stored. Save file should have ".tox" extension.
 * See Tox STS for more information: https://github.com/Tox/Tox-STS
 *
 * @return Full path to the file for loading/saving tox data.
 *
 * @warning Path should be file path. The file can be rewritten at any time while OCTManager is alive.
 */
@property (readonly) NSString *pathForToxSaveFile;

/**
 * Returns file path for database to be stored in. Must be path to a file, not directory.
 * In database will be stored chats, messages and related stuff.
 *
 * @return Full path to the file for the database.
 *
 * @warning Path should be file path. The file can be rewritten at any time while OCTManager is alive.
 */
@property (readonly) NSString *pathForDatabase;

/**
 * Returns path where all downloaded files will be stored.
 *
 * @return Full path to the directory with downloaded files.
 */
@property (readonly) NSString *pathForDownloadedFilesDirectory;

/**
 * Returns path where all uploaded files will be stored.
 *
 * @return Full path to the directory with uploaded files.
 */
@property (readonly) NSString *pathForUploadedFilesDirectory;

/**
 * Returns path where temporary files will be stored. This directory can be cleaned on relaunch of app.
 * You can use NSTemporaryDirectory() here.
 *
 * @return Full path to the directory with temporary files.
 */
@property (readonly) NSString *pathForTemporaryFilesDirectory;

/**
 * Returns path where all avatar images will be stored.
 *
 * @return Full path to the directory with avatar images.
 */
@property (readonly) NSString *pathForAvatarsDirectory;

@end
