//
//  OCTDBMessageFile.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 24.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTDBMessageFile.h"
#import "OCTMessageFile+Private.h"

@implementation OCTDBMessageFile

- (instancetype)initWithMessageFile:(OCTMessageFile *)message
{
    self = [super init];

    if (! self) {
        return nil;
    }

    self.fileType = message.fileType;
    self.fileSize = message.fileSize;
    self.fileName = message.fileName;
    self.filePath = message.filePath;
    self.fileUTI = message.fileUTI;

    return self;
}

@end
