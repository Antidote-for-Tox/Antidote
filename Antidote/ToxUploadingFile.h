//
//  ToxUploadingFile.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 31.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSUInteger kToxUploadingFilesMaxNumberOfFailures = 500;
static const NSTimeInterval kToxUploadingFilesUIUpdateInterval = 0.3;

@interface ToxUploadingFile : NSObject

@property (assign, nonatomic, readonly) uint64_t fileSize;
@property (assign, nonatomic, readonly) uint16_t portionSize;

@property (assign, nonatomic) BOOL paused;
@property (assign, nonatomic) NSUInteger numberOfFailuresInARow;

@property (strong, nonatomic) NSDate *lastUIUpdateDate;

- (instancetype)initWithFilePath:(NSString *)filePath portionSize:(uint16_t)portionSize;

// Returns length of portion. If there is no more data returns 0.
- (uint16_t)nextPortionOfBytes:(void *)buffer;
- (void)goForwardOnLength:(uint16_t)length;

- (uint64_t)uploadedLength;

- (void)finishUploading;

@end
