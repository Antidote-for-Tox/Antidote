//
//  OCTDefaultFileStorage.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 08.03.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTDefaultFileStorage.h"

@interface OCTDefaultFileStorage()

@property (copy, nonatomic) NSString *saveFileName;
@property (copy, nonatomic) NSString *baseDirectory;
@property (copy, nonatomic) NSString *temporaryDirectory;

@end

@implementation OCTDefaultFileStorage

#pragma mark -  Lifecycle

- (instancetype)initWithBaseDirectory:(NSString *)baseDirectory temporaryDirectory:(NSString *)temporaryDirectory
{
    return [self initWithToxSaveFileName:nil baseDirectory:baseDirectory temporaryDirectory:temporaryDirectory];
}

- (instancetype)initWithToxSaveFileName:(NSString *)saveFileName
                          baseDirectory:(NSString *)baseDirectory
                     temporaryDirectory:(NSString *)temporaryDirectory
{
    self = [super init];

    if (! self) {
        return nil;
    }

    if (! saveFileName) {
        saveFileName = @"save";
    }

    self.saveFileName = [saveFileName stringByAppendingString:@".tox"];
    self.baseDirectory = baseDirectory;
    self.temporaryDirectory = temporaryDirectory;

    return self;
}

#pragma mark -  OCTFileStorageProtocol

- (NSString *)pathForToxSaveFile
{
    return [self.baseDirectory stringByAppendingPathComponent:self.saveFileName];
}

- (NSString *)pathForDatabase
{
    return [self.baseDirectory stringByAppendingPathComponent:@"database"];
}

- (NSString *)pathForDownloadedFilesDirectory
{
    return [self.baseDirectory stringByAppendingPathComponent:@"downloads"];
}

- (NSString *)pathForUploadedFilesDirectory
{
    return [self.baseDirectory stringByAppendingPathComponent:@"uploads"];
}

- (NSString *)pathForTemporaryFilesDirectory
{
    return self.temporaryDirectory;
}

- (NSString *)pathForAvatarsDirectory
{
    return [self.baseDirectory stringByAppendingPathComponent:@"avatars"];
}

@end
