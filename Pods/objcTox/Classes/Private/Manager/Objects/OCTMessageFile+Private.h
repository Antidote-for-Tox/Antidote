//
//  OCTMessageFile+Private.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 24.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTMessageFile.h"

@interface OCTMessageFile (Private)

@property (assign, nonatomic, readwrite) OCTMessageFileType fileType;
@property (assign, nonatomic, readwrite) OCTToxFileSize fileSize;
@property (strong, nonatomic, readwrite) NSString *fileName;
@property (strong, nonatomic, readwrite) NSString *filePath;
@property (strong, nonatomic, readwrite) NSString *fileUTI;

@end
