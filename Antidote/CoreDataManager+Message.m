//
//  CoreDataManager+Message.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 26.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CoreDataManager+Message.h"
#import "CoreData+MagicalRecord.h"

@implementation CoreDataManager (Message)

+ (NSArray *)messagesWithPredicate:(NSPredicate *)predicate
{
    __block NSArray *array;

    dispatch_sync([self private_queue], ^{
        array = [CDMessage MR_findAllSortedBy:@"date" ascending:YES withPredicate:predicate];
    });

    return array;
}

+ (CDMessage *)insertMessageWithConfigBlock:(void (^)(CDMessage *theMessage))configBlock;
{
    if (! configBlock) {
        return nil;
    }

    __block CDMessage *message;

    dispatch_sync([self private_queue], ^{
        message = [NSEntityDescription insertNewObjectForEntityForName:@"CDMessage"
                                                inManagedObjectContext:[self private_context]];

        configBlock(message);

        [[self private_context] MR_saveToPersistentStoreAndWait];
    });

    return message;
}

+ (CDMessage *)editMessageWithId:(NSNumber *)messageId editBlock:(void (^)(CDMessage *theMessage))editBlock;
{
    if (! messageId || ! editBlock) {
        return nil;
    }

    __block CDMessage *editedMessage;

    dispatch_sync([self private_queue], ^{
        editedMessage = [self messageWithId:messageId];

        if (editedMessage) {
            editBlock(editedMessage);

            [[self private_context] MR_saveToPersistentStoreAndWait];
        }
    });

    return editedMessage;
}

+ (void)removeAllMessages
{
    dispatch_sync([self private_queue], ^{
        for (CDMessage *message in [CDMessage MR_findAllInContext:[self private_context]]) {
            [message MR_deleteInContext:[self private_context]];
        }

        [[self private_context] MR_saveToPersistentStoreAndWait];
    });
}

#pragma mark -  Private

+ (CDMessage *)messageWithId:(NSNumber *)messageId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", messageId];

    NSArray *array = [CDMessage MR_findAllWithPredicate:predicate inContext:[self private_context]];

    return [array lastObject];
}


@end
