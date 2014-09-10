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
 * kCoreDataManagerCDMessageKey - containing appropriate CDMessage
 */
extern NSString *const kCoreDataManagerNewMessageNotification;
extern NSString *const kCoreDataManagerMessageUpdateNotification;

extern NSString *const kCoreDataManagerCDMessageKey;

typedef NS_ENUM(NSUInteger, CDMessageType) {
    CDMessageTypeText,
    CDMessageTypeFile,
    CDMessageTypePendingFile,
    CDMessageTypeCall,
};

@interface CoreDataManager (Message)

+ (void)fetchedControllerForMessagesFromChat:(CDChat *)chat
                             completionQueue:(dispatch_queue_t)queue
                             completionBlock:(void (^)(NSFetchedResultsController *controller))completionBlock;

+ (void)messagesWithPredicate:(NSPredicate *)predicate
              completionQueue:(dispatch_queue_t)queue
              completionBlock:(void (^)(NSArray *messages))completionBlock;

+ (void)insertMessageWithType:(CDMessageType)type
                  configBlock:(void (^)(CDMessage *message))configBlock
              completionQueue:(dispatch_queue_t)queue
              completionBlock:(void (^)(CDMessage *message))completionBlock;

+ (void)editCDMessageAndSendNotificationsWithMessage:(CDMessage *)message
                                               block:(void (^)())block
                                     completionQueue:(dispatch_queue_t)queue
                                     completionBlock:(void (^)())completionBlock;

+ (void)movePendingFileToFileForMessage:(CDMessage *)message
                        completionQueue:(dispatch_queue_t)queue
                        completionBlock:(void (^)())completionBlock;

@end
