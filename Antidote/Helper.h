//
//  Helper.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 08.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StatusCircleView.h"
#import "OCTFriend.h"
#import "RBQFetchedResultsController.h"
#import "OCTManager.h"

@interface Helper : NSObject

+ (BOOL)isAddressString:(NSString *)string;

+ (StatusCircleStatus)circleStatusFromFriend:(OCTFriend *)friend;

+ (StatusCircleStatus)circleStatusFromUserStatus:(OCTToxUserStatus)userStatus;

+ (StatusCircleStatus)circleStatusFromConnectionStatus:(OCTToxConnectionStatus)connectionStatus
                                            userStatus:(OCTToxUserStatus)userStatus;

+ (NSString *)circleStatusToString:(StatusCircleStatus)status;

+ (RBQFetchedResultsController *)createFetchedResultsControllerForType:(OCTFetchRequestType)type
                                                              delegate:(id<RBQFetchedResultsControllerDelegate>)delegate;

+ (RBQFetchedResultsController *)createFetchedResultsControllerForType:(OCTFetchRequestType)type
                                                             predicate:(NSPredicate *)predicate
                                                              delegate:(id<RBQFetchedResultsControllerDelegate>)delegate;

+ (RBQFetchedResultsController *)createFetchedResultsControllerForType:(OCTFetchRequestType)type
                                                             predicate:(NSPredicate *)predicate
                                                       sortDescriptors:(NSArray *)sortDescriptors
                                                              delegate:(id<RBQFetchedResultsControllerDelegate>)delegate;

@end
