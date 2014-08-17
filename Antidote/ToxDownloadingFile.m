//
//  ToxDownloadingFile.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 17.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxDownloadingFile.h"

static const NSTimeInterval kCacheTimeInterval = 0.3;

@interface ToxDownloadingFile()

@property (strong, nonatomic) NSFileHandle *fileHandle;

@property (strong, nonatomic) NSMutableData *cachedData;

@property (assign, nonatomic) NSTimeInterval lastWriteTimeInterval;

@property (assign, nonatomic, readwrite) unsigned long long savedLength;

@end

@implementation ToxDownloadingFile

- (instancetype)initWithFilePath:(NSString *)filePath
{
    if (! filePath) {
        return nil;
    }

    self = [super init];

    if (self) {
        NSFileManager *manager = [NSFileManager defaultManager];

        if (! [manager fileExistsAtPath:filePath]) {

            [manager createDirectoryAtPath:[filePath stringByDeletingLastPathComponent]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];

            [manager createFileAtPath:filePath contents:nil attributes:nil];
        }

        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [self.fileHandle seekToEndOfFile];

        self.savedLength = [self.fileHandle offsetInFile];

        self.cachedData = [NSMutableData new];
        self.lastWriteTimeInterval = [self currentTimeInterval];
    }

    return self;
}

- (void)appendData:(NSData *)data didSavedOnDisk:(BOOL *)didSavedOnDisk
{
    @synchronized(self) {
        [self.cachedData appendData:data];

        NSTimeInterval currentTimeInterval = [self currentTimeInterval];

        if (currentTimeInterval < self.lastWriteTimeInterval + kCacheTimeInterval) {
            if (didSavedOnDisk) {
                *didSavedOnDisk = NO;
            }
            return;
        }

        self.savedLength += self.cachedData.length;
        self.lastWriteTimeInterval = currentTimeInterval;

        [self.fileHandle writeData:self.cachedData];
        self.cachedData = [NSMutableData new];

        if (didSavedOnDisk) {
            *didSavedOnDisk = YES;
        }
    }
}

- (void)finishDownloading
{
    @synchronized(self) {
        if (self.cachedData.length) {
            [self.fileHandle writeData:self.cachedData];
        }

        [self.fileHandle closeFile];
        self.fileHandle = nil;
    }
}

#pragma mark -  Private

- (NSTimeInterval)currentTimeInterval
{
    return [[NSDate date] timeIntervalSince1970];
}

@end
