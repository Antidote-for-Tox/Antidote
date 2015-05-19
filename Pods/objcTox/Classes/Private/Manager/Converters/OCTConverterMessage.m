//
//  OCTConverterMessage.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 05.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTConverterMessage.h"
#import "OCTMessageAbstract+Private.h"
#import "OCTMessageText+Private.h"
#import "OCTMessageFile+Private.h"
#import "OCTDBMessageAbstract.h"

@implementation OCTConverterMessage

#pragma mark -  OCTConverterProtocol

- (NSString *)objectClassName
{
    return NSStringFromClass([OCTMessageAbstract class]);
}

- (NSObject *)objectFromRLMObject:(OCTDBMessageAbstract *)db
{
    NSParameterAssert(db);

    OCTMessageAbstract *message;

    if (db.textMessage) {
        message = [self textMessageFromDBMessage:db.textMessage];
    }
    else if (db.fileMessage) {
        message = [self fileMessageFromDBMessage:db.fileMessage];
    }

    message.date = [NSDate dateWithTimeIntervalSince1970:db.dateInterval];
    if (db.sender) {
        message.sender = (OCTFriend *)[self.converterFriend objectFromRLMObject:db.sender];
    }

    return message;
}

- (RLMSortDescriptor *)rlmSortDescriptorFromDescriptor:(OCTSortDescriptor *)descriptor
{
    NSParameterAssert(descriptor);

    NSDictionary *mapping = @{
        NSStringFromSelector(@selector(date)) : NSStringFromSelector(@selector(dateInterval)),
    };

    NSString *rlmProperty = mapping[descriptor.property];

    if (! rlmProperty) {
        return nil;
    }

    return [RLMSortDescriptor sortDescriptorWithProperty:rlmProperty ascending:descriptor.ascending];
}

#pragma mark -  Private

- (OCTMessageText *)textMessageFromDBMessage:(OCTDBMessageText *)db
{
    OCTMessageText *message = [OCTMessageText new];
    message.text = db.text;
    message.isDelivered = db.isDelivered;

    return message;
}

- (OCTMessageFile *)fileMessageFromDBMessage:(OCTDBMessageFile *)db
{
    OCTMessageFile *message = [OCTMessageFile new];
    message.fileType = db.fileType;
    message.fileSize = db.fileSize;
    message.fileName = db.fileName;
    message.filePath = db.filePath;
    message.fileUTI = db.fileUTI;

    return message;
}

@end
