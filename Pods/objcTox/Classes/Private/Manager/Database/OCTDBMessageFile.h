//
//  OCTDBMessageFile.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 24.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Realm/Realm.h>
#import "OCTMessageFile.h"

@interface OCTDBMessageFile : RLMObject

@property int fileType;
@property long long fileSize;
@property NSString *fileName;
@property NSString *filePath;
@property NSString *fileUTI;

- (instancetype)initWithMessageFile:(OCTMessageFile *)message;

@end
