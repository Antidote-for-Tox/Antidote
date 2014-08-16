//
//  CDMessagePendingFile.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 16.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDMessage;

@interface CDMessagePendingFile : NSManagedObject

@property (nonatomic) BOOL isActive;
@property (nonatomic) uint16_t fileNumber;
@property (nonatomic) int32_t friendNumber;
@property (nonatomic) uint64_t fileSize;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * documentPath;
@property (nonatomic) uint64_t loadedSize;

@property (nonatomic, retain) CDMessage *messageInverse;

@end
