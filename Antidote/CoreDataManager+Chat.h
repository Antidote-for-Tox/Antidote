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

+ (NSArray *)allChatsSortedByDate;
+ (NSArray *)chatsWithPredicateSortedByDate:(NSPredicate *)predicate;

+ (NSFetchedResultsController *)allChatsFetchedControllerWithDelegate:(id <NSFetchedResultsControllerDelegate>)delegate;

+ (CDChat *)getOrInsertChatWithPredicate:(NSPredicate *)predicate configBlock:(void (^)(CDChat *theChat))configBlock;

+ (void)removeChatWithAllMessages:(CDChat *)chat;

@end
