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

typedef NS_ENUM(int16_t, CDMessagePendingFileState) {
    CDMessagePendingFileStateWaitingConfirmation,
    CDMessagePendingFileStateActive,
    CDMessagePendingFileStatePaused,
    CDMessagePendingFileStateCanceled,
};

@interface CDMessagePendingFile : NSManagedObject

@property (nonatomic) int16_t state;
@property (nonatomic) uint16_t fileNumber;
@property (nonatomic) int32_t friendNumber;
@property (nonatomic) uint64_t fileSize;
@property (nonatomic, retain) NSString * originalFileName;
@property (nonatomic, retain) NSString * fileNameOnDisk;
@property (nonatomic, retain) NSString * fileUTI;

@property (nonatomic, retain) CDMessage *messageInverse;

@end
