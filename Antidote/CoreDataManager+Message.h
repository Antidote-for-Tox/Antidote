//
//  CoreDataManager+Message.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 26.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CoreDataManager.h"
#import "CDMessage.h"

/**
 * userInfo will contain dictionary with following keys:
 * kCoreDataManagerNewMessageKey - containing appropriate CDMessage
 */
extern NSString *const kCoreDataManagerNewMessageNotification;
extern NSString *const kCoreDataManagerNewMessageKey;

@interface CoreDataManager (Message)

+ (NSArray *)messagesForChat:(CDChat *)chat;

+ (NSFetchedResultsController *)messagesFetchedControllerForChat:(CDChat *)chat
                                                    withDelegate:(id <NSFetchedResultsControllerDelegate>)delegate;

+ (CDMessage *)insertMessageWithConfigBlock:(void (^)(CDMessage *theMessage))configBlock;
+ (CDMessage *)editMessageWithId:(NSNumber *)messageId editBlock:(void (^)(CDMessage *theMessage))editBlock;

+ (void)removeAllMessages;

@end
