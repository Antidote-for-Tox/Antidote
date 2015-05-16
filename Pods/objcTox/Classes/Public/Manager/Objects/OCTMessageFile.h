//
//  OCTMessageFile.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 15.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTMessageAbstract.h"
#import "OCTToxConstants.h"
#import "OCTManagerConstants.h"

/**
 * Message that contains file, that has been send/received. Represents pending, canceled and loaded files.
 */
@interface OCTMessageFile : OCTMessageAbstract

/**
 * The current state of file. Only in case if it is OCTMessageFileTypeReady
 * the file can be shown to user.
 */
@property (assign, nonatomic, readonly) OCTMessageFileType fileType;

/**
 * Size of file in bytes.
 */
@property (assign, nonatomic, readonly) OCTToxFileSize fileSize;

/**
 * Name of the file as specified by sender. Note that actual fileName in path
 * may differ from this fileName.
 */
@property (strong, nonatomic, readonly) NSString *fileName;

/**
 * Path of file on disk. If you need fileName to show to user please use
 * `fileName` property. filePath has it's own random fileName.
 */
@property (strong, nonatomic, readonly) NSString *filePath;

/**
 * Uniform Type Identifier of file.
 */
@property (strong, nonatomic, readonly) NSString *fileUTI;

@end
