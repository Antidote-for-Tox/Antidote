//
//  ToxUploadingFile.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 31.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxUploadingFile.h"

@interface ToxUploadingFile()

@property (strong, nonatomic) NSFileHandle *fileHandle;
@property (strong, nonatomic) NSData *cachedData;

@property (assign, nonatomic) NSUInteger offsetInCachedData;

@property (assign, nonatomic) uint16_t portionSize;

@property (assign, nonatomic, readwrite) uint64_t fileSize;

@end

@implementation ToxUploadingFile

#pragma mark -  Lifecycle

- (instancetype)initWithFilePath:(NSString *)filePath portionSize:(uint16_t)portionSize
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (! [fileManager fileExistsAtPath:filePath]) {
        DDLogError(@"ToxUploadingFile: %@ file does not exist at path %@, returning nil in init", self, filePath);

        return nil;
    }

    self = [super init];

    if (self) {
        self.portionSize = portionSize;

        self.fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];

        [self.fileHandle seekToEndOfFile];
        self.fileSize = [self.fileHandle offsetInFile];
        [self.fileHandle seekToFileOffset:0];

        DDLogInfo(@"ToxUploadingFile: %@ inited with portionSize %u, fileSize %llu",
                self, self.portionSize, self.fileSize);
    }

    return self;
}

#pragma mark -  Public

- (uint16_t)nextPortionOfBytes:(void *)buffer
{
    if (! self.cachedData) {
        DDLogInfo(@"ToxUploadingFile: %@ nextPortionOfBytes: no cached data, caching...", self);

        self.cachedData = [self.fileHandle availableData];

        if (! self.cachedData) {
            DDLogInfo(@"ToxUploadingFile: %@ nextPortionOfBytes: no cached data, caching... no more data available",
                    self);

            return 0;
        }

        DDLogInfo(@"ToxUploadingFile: %@ nextPortionOfBytes: no cached data, caching... cached %lu bytes",
                self, self.cachedData.length);
    }

    NSUInteger offset = self.offsetInCachedData;
    NSUInteger length = MIN(self.portionSize, self.cachedData.length - offset);

    [self.cachedData getBytes:buffer range:NSMakeRange(offset, length)];

    self.offsetInCachedData += length;

    if (self.offsetInCachedData == self.cachedData.length) {
        self.cachedData = nil;
        self.offsetInCachedData = 0;
    }

    return length;
}

- (void)finishUploading
{
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    self.cachedData = nil;

    DDLogInfo(@"ToxUploadingFile: %@ finish uploading... file closed", self);
}

@end
