//
//  CoreDataManager+Message.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 26.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CoreDataManager.h"
#import "CDMessage.h"

@interface CoreDataManager (Message)

+ (NSArray *)messagesWithPredicateSortedByDate:(NSPredicate *)predicate;

+ (CDMessage *)insertMessageWithConfigBlock:(void (^)(CDMessage *theMessage))configBlock;
+ (CDMessage *)editMessageWithId:(NSNumber *)messageId editBlock:(void (^)(CDMessage *theMessage))editBlock;

+ (void)removeAllMessages;

@end
