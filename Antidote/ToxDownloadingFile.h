//
//  ToxDownloadingFile.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 17.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToxDownloadingFile : NSObject

@property (assign, nonatomic, readonly) unsigned long long savedLength;

- (instancetype)initWithFilePath:(NSString *)filePath;

- (void)appendData:(NSData *)data didSavedOnDisk:(BOOL *)didSavedOnDisk;
- (void)finishDownloading;

@end
