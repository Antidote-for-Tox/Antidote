//
//  CoreDataManager+Chat.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CoreDataManager+Chat.h"
#import "CoreData+MagicalRecord.h"

@implementation CoreDataManager (Chat)

+ (void)chatsWithPredicateSortedByDate:(NSPredicate *)predicate
                       completionQueue:(dispatch_queue_t)queue
                       completionBlock:(void (^)(NSArray *chats))completionBlock
{
    if (! completionBlock) {
        return;
    }

    dispatch_async([self private_queue], ^{
        NSArray *array = [CDChat MR_findAllSortedBy:@"lastMessage.date"
                                          ascending:YES
                                      withPredicate:predicate
                                          inContext:[self private_context]];

        [self private_performBlockOnQueueOrMain:queue block:^{
            completionBlock(array);
        }];
    });
}

+ (void)allChatsFetchedControllerWithDelegate:(id <NSFetchedResultsControllerDelegate>)delegate
                              completionQueue:(dispatch_queue_t)queue
                              completionBlock:(void (^)(NSFetchedResultsController *controller))completionBlock
{
    if (! completionBlock) {
        return;
    }

    dispatch_async([self private_queue], ^{
        NSFetchedResultsController *controller = [CDChat MR_fetchAllSortedBy:@"lastMessage.date"
                                                                   ascending:NO
                                                               withPredicate:nil
                                                                     groupBy:nil
                                                                    delegate:delegate
                                                                   inContext:[self private_context]];

        [self private_performBlockOnQueueOrMain:queue block:^{
            completionBlock(controller);
        }];
    });
}

+ (void)getOrInsertChatWithPredicate:(NSPredicate *)predicate
                         configBlock:(void (^)(CDChat *theChat))configBlock
                     completionQueue:(dispatch_queue_t)queue
                     completionBlock:(void (^)(CDChat *chat))completionBlock
{
    dispatch_async([self private_queue], ^{
        CDChat *chat = [CDChat MR_findFirstWithPredicate:predicate inContext:[self private_context]];

        if (! chat) {
            chat = [NSEntityDescription insertNewObjectForEntityForName:@"CDChat"
                                                 inManagedObjectContext:[self private_context]];

            if (configBlock) {
                configBlock(chat);
            }

            [[self private_context] MR_saveToPersistentStoreAndWait];

            DDLogVerbose(@"CoreDataManager: inserted chat %@", chat);
        }

        if (! completionBlock) {
            return;
        }

        [self private_performBlockOnQueueOrMain:queue block:^{
            completionBlock(chat);
        }];
    });
}

+ (void)removeChatWithAllMessages:(CDChat *)chat
                  completionQueue:(dispatch_queue_t)queue
                  completionBlock:(void (^)())completionBlock
{
    dispatch_async([self private_queue], ^{
        DDLogVerbose(@"CoreDataManager+Chat: deleting chat with all messages %@", chat);

        [chat MR_deleteInContext:[self private_context]];

        [[self private_context] MR_saveToPersistentStoreAndWait];

        [self private_performBlockOnQueueOrMain:queue block:completionBlock];
    });
}

@end
