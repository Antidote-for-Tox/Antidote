//
//  CoreDataManager+Chat.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CoreDataManager+Chat.h"
#import "CoreData+MagicalRecord.h"
#import "ProfileManager.h"

@implementation CoreDataManager (Chat)

+ (void)currentProfileChatsWithPredicateSortedByDate:(NSPredicate *)predicate
                                     completionQueue:(dispatch_queue_t)queue
                                     completionBlock:(void (^)(NSArray *chats))completionBlock
{
    if (! completionBlock) {
        return;
    }

    predicate = [self private_predicateByAddingCurrentProfile:predicate];

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

+ (void)currentProfileAllChatsFetchedControllerWithDelegate:(id <NSFetchedResultsControllerDelegate>)delegate
                                            completionQueue:(dispatch_queue_t)queue
                                            completionBlock:(void (^)(NSFetchedResultsController *controller))completionBlock
{
    if (! completionBlock) {
        return;
    }

    dispatch_async([self private_queue], ^{
        NSPredicate *predicate = [self private_predicateByAddingCurrentProfile:nil];

        NSFetchedResultsController *controller = [CDChat MR_fetchAllSortedBy:@"lastMessage.date"
                                                                   ascending:NO
                                                               withPredicate:predicate
                                                                     groupBy:nil
                                                                    delegate:delegate
                                                                   inContext:[self private_context]];

        [self private_performBlockOnQueueOrMain:queue block:^{
            completionBlock(controller);
        }];
    });
}

+ (void)chatWithURIRepresentation:(NSURL *)uriRepresentation
                  completionQueue:(dispatch_queue_t)queue
                  completionBlock:(void (^)(CDChat *chat))completionBlock
{
    if (! completionBlock) {
        return;
    }

    dispatch_async([self private_queue], ^{
        NSManagedObjectContext *context = [self private_context];
        NSPersistentStoreCoordinator *coordinator = context.persistentStoreCoordinator;

        NSManagedObjectID *objectId = [coordinator managedObjectIDForURIRepresentation:uriRepresentation];

        CDChat *chat = (CDChat *) [context objectWithID:objectId];

        [self private_performBlockOnQueueOrMain:queue block:^{
            completionBlock(chat);
        }];
    });
}

+ (void)getOrInsertChatWithPredicateInCurrentProfile:(NSPredicate *)predicate
                                         configBlock:(void (^)(CDChat *theChat))configBlock
                                     completionQueue:(dispatch_queue_t)queue
                                     completionBlock:(void (^)(CDChat *chat))completionBlock
{
    predicate = [self private_predicateByAddingCurrentProfile:predicate];

    dispatch_async([self private_queue], ^{
        CDChat *chat = [CDChat MR_findFirstWithPredicate:predicate inContext:[self private_context]];

        if (! chat) {
            chat = [NSEntityDescription insertNewObjectForEntityForName:@"CDChat"
                                                 inManagedObjectContext:[self private_context]];

            chat.profile = [ProfileManager sharedInstance].currentProfile;

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
