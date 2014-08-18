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
        DDLogInfo(@"ToxDownloadingFile: initing... %@ with cacheTimeInterval %f", self, kCacheTimeInterval);

        NSFileManager *manager = [NSFileManager defaultManager];

        if (! [manager fileExistsAtPath:filePath]) {
            DDLogInfo(@"ToxDownloadingFile: initing... there is no file, creating new one");

            NSError *error;

            [manager createDirectoryAtPath:[filePath stringByDeletingLastPathComponent]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];

            if (error) {
                DDLogError(@"ToxDownloadingFile: initing... cannot create directory, returning nil, error %@", error);

                return nil;
            }

            BOOL created = [manager createFileAtPath:filePath contents:nil attributes:nil];

            if (! created) {
                DDLogError(@"ToxDownloadingFile: initing... cannot create file, returning nil");

                return nil;
            }
        }

        self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [self.fileHandle seekToEndOfFile];

        self.savedLength = [self.fileHandle offsetInFile];

        self.cachedData = [NSMutableData new];
        self.lastWriteTimeInterval = [self currentTimeInterval];

        DDLogInfo(@"ToxDownloadingFile: initing... inited with fileHandle %@, savedLength %llu",
                self.fileHandle, self.savedLength);
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

        DDLogInfo(@"ToxDownloadingFile: %@ appending %lu bytes to file", self, self.cachedData.length);

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
        DDLogInfo(@"ToxDownloadingFile: %@ finish downloading...", self);

        if (self.cachedData.length) {
            DDLogInfo(@"ToxDownloadingFile: %@ appending %lu bytes to file", self, (unsigned long)self.cachedData.length);
            [self.fileHandle writeData:self.cachedData];
        }

        [self.fileHandle closeFile];
        self.fileHandle = nil;

        DDLogInfo(@"ToxDownloadingFile: %@ finish downloading... file closed", self);
    }
}

#pragma mark -  Private

- (NSTimeInterval)currentTimeInterval
{
    return [[NSDate date] timeIntervalSince1970];
}

@end
