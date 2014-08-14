//
//  CoreDataManager+Message.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 26.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CoreDataManager+Message.h"
#import "CoreData+MagicalRecord.h"

NSString *const kCoreDataManagerNewMessageNotification = @"kCoreDataManagerNewMessageNotification";
NSString *const kCoreDataManagerNewMessageKey = @"kCoreDataManagerNewMessageKey";

@implementation CoreDataManager (Message)

+ (void)messagesForChat:(CDChat *)chat
        completionQueue:(dispatch_queue_t)queue
        completionBlock:(void (^)(NSArray *messages))completionBlock;
{
    if (! completionBlock) {
        return;
    }

    dispatch_async([self private_queue], ^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chat == %@", chat];

        NSArray *array = [CDMessage MR_findAllSortedBy:@"date"
                                             ascending:YES
                                         withPredicate:predicate
                                             inContext:[self private_context]];

        [self private_performBlockOnQueueOrMain:queue block:^{
            completionBlock(array);
        }];
    });
}

+ (void)insertTextMessageWithConfigBlock:(void (^)(CDMessage *message))configBlock
                         completionQueue:(dispatch_queue_t)queue
                         completionBlock:(void (^)(CDMessage *message))completionBlock
{
    dispatch_async([self private_queue], ^{
        CDMessage *message = [NSEntityDescription insertNewObjectForEntityForName:@"CDMessage"
                                                           inManagedObjectContext:[self private_context]];

        message.text = [NSEntityDescription insertNewObjectForEntityForName:@"CDMessageText"
                                                     inManagedObjectContext:[self private_context]];

        if (configBlock) {
            configBlock(message);
        }

        [[self private_context] MR_saveToPersistentStoreAndWait];

        if (completionBlock) {
            [self private_performBlockOnQueueOrMain:queue block:^{
                completionBlock(message);
            }];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kCoreDataManagerNewMessageNotification
                                                                object:nil
                                                              userInfo:@{kCoreDataManagerNewMessageKey: message}];
        });
    });
}

@end
