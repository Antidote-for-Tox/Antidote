//
//  CoreDataManager+Chat.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CoreDataManager.h"
#import "CDChat.h"

@interface CoreDataManager (Chat)

+ (void)chatsWithPredicateSortedByDate:(NSPredicate *)predicate
                       completionQueue:(dispatch_queue_t)queue
                       completionBlock:(void (^)(NSArray *chats))completionBlock;

+ (void)allChatsFetchedControllerWithDelegate:(id <NSFetchedResultsControllerDelegate>)delegate
                              completionQueue:(dispatch_queue_t)queue
                              completionBlock:(void (^)(NSFetchedResultsController *controller))completionBlock;

+ (void)getOrInsertChatWithPredicate:(NSPredicate *)predicate
                         configBlock:(void (^)(CDChat *theChat))configBlock
                     completionQueue:(dispatch_queue_t)queue
                     completionBlock:(void (^)(CDChat *chat))completionBlock;

+ (void)removeChatWithAllMessages:(CDChat *)chat
                  completionQueue:(dispatch_queue_t)queue
                  completionBlock:(void (^)())completionBlock;

@end
