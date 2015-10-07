//
//  FileManager.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 15/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

/**
 * Move file from given url to pending files directory.
 *
 * @param url URL of file to move.
 *
 * @return New url of file in pending files directory.
 */
- (NSURL *)moveFileToPendingFiles:(NSURL *)url;

/**
 * Removes all files from pending files directory.
 */
- (void)clearPendingFilesDirectory;

@end
