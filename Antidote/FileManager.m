//
//  FileManager.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 15/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "FileManager.h"

#define LOG_IDENTIFIER @"FileManager"

@implementation FileManager

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    NSArray *directories = @[
        [self filesDirectory],
        [self pendingFilesDirectory],
    ];

    NSFileManager *manager = [NSFileManager defaultManager];

    for (NSString *path in directories) {
        AALogInfo(@"Creating directory at path: %@", path);
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return self;
}

#pragma mark -  Public

- (NSURL *)moveFileToPendingFiles:(NSURL *)url
{
    AALogInfo(@"%@", url);

    NSError *error;
    NSString *pendingPath = [[self pendingFilesDirectory] stringByAppendingPathComponent:[url lastPathComponent]];

    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:pendingPath]) {
        AALogInfo(@"file already exists, removing it");

        if (! [manager removeItemAtPath:pendingPath error:&error]) {
            AALogWarn(@"file already exists, removing it... error occured %@", error);
        }
    }

    NSURL *pendingURL = [NSURL fileURLWithPath:pendingPath isDirectory:NO];

    if (! [manager moveItemAtURL:url toURL:pendingURL error:&error]) {
        AALogWarn(@"move file... error occured %@", error);
    }

    AALogInfo(@"done");

    return pendingURL;
}

- (void)clearPendingFilesDirectory
{
    NSFileManager *manager = [NSFileManager defaultManager];

    NSString *pending = [self pendingFilesDirectory];

    AALogInfo(@"files to delete: %@", [manager contentsOfDirectoryAtPath:pending error:nil]);

    [manager removeItemAtPath:pending error:nil];
    [manager createDirectoryAtPath:pending withIntermediateDirectories:YES attributes:nil error:nil];
}

#pragma mark -  Private

- (NSString *)filesDirectory
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [path stringByAppendingPathComponent:@"Files"];
}

- (NSString *)pendingFilesDirectory
{
    return [[self filesDirectory] stringByAppendingPathComponent:@"Pending"];
}

@end
