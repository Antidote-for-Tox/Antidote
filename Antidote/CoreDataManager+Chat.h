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
+ (NSFetchedResultsController *)allChatsFetchedControllerWithDelegate:(id <NSFetchedResultsControllerDelegate>)delegate;

@end
