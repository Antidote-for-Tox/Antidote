//
//  Helper.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 08.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <objcTox/OCTSubmanagerObjects.h>
#import <objcTox/OCTToxConstants.h>

#import "Helper.h"
#import "RunningContext.h"

NSString *const kToxSaveFileExtension = @"tox";

@implementation Helper

#pragma mark -  Public

+ (BOOL)isAddressString:(NSString *)string
{
    if (string.length != kOCTToxAddressLength) {
        return NO;
    }

    NSCharacterSet *validChars = [NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefABCDEF"];

    NSArray *components = [string componentsSeparatedByCharactersInSet:validChars];

    NSString *leftChars = [components componentsJoinedByString:@""];

    return (leftChars.length == 0);
}

+ (StatusCircleStatus)circleStatusFromFriend:(OCTFriend *)friend
{
    return [self circleStatusFromConnectionStatus:friend.connectionStatus userStatus:friend.status];
}

+ (StatusCircleStatus)circleStatusFromUserStatus:(OCTToxUserStatus)userStatus
{
    // Using TCP as any "connected" status.
    return [self circleStatusFromConnectionStatus:OCTToxConnectionStatusTCP userStatus:userStatus];
}

+ (StatusCircleStatus)circleStatusFromConnectionStatus:(OCTToxConnectionStatus)connectionStatus
                                            userStatus:(OCTToxUserStatus)userStatus
{
    if (connectionStatus == OCTToxConnectionStatusNone) {
        return StatusCircleStatusOffline;
    }

    switch (userStatus) {
        case OCTToxUserStatusNone:
            return StatusCircleStatusOnline;
        case OCTToxUserStatusAway:
            return StatusCircleStatusAway;
        case OCTToxUserStatusBusy:
            return StatusCircleStatusBusy;
    }
}

+ (NSString *)circleStatusToString:(StatusCircleStatus)status
{
    switch (status) {
        case StatusCircleStatusOffline:
            return NSLocalizedString(@"Offline", @"User status");
        case StatusCircleStatusOnline:
            return NSLocalizedString(@"Online", @"User status");
        case StatusCircleStatusAway:
            return NSLocalizedString(@"Away", @"User status");
        case StatusCircleStatusBusy:
            return NSLocalizedString(@"Busy", @"User status");
    }
}

+ (RBQFetchedResultsController *)createFetchedResultsControllerForType:(OCTFetchRequestType)type
                                                              delegate:(id<RBQFetchedResultsControllerDelegate>)delegate
{
    return [self createFetchedResultsControllerForType:type predicate:nil delegate:delegate];
}

+ (RBQFetchedResultsController *)createFetchedResultsControllerForType:(OCTFetchRequestType)type
                                                             predicate:(NSPredicate *)predicate
                                                              delegate:(id<RBQFetchedResultsControllerDelegate>)delegate
{
    return [self createFetchedResultsControllerForType:type
                                             predicate:predicate
                                       sortDescriptors:nil
                                              delegate:delegate];
}

+ (RBQFetchedResultsController *)createFetchedResultsControllerForType:(OCTFetchRequestType)type
                                                             predicate:(NSPredicate *)predicate
                                                       sortDescriptors:(NSArray *)sortDescriptors
                                                              delegate:(id<RBQFetchedResultsControllerDelegate>)delegate
{
    OCTSubmanagerObjects *submanager = [RunningContext context].toxManager.objects;

    RBQFetchRequest *fetchRequest = [submanager fetchRequestForType:type withPredicate:predicate];
    fetchRequest.sortDescriptors = sortDescriptors;
    RBQFetchedResultsController *controller = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                     sectionNameKeyPath:nil
                                                                                              cacheName:nil];
    controller.delegate = delegate;
    [controller performFetch];

    return controller;
}

+ (void)updateFetchedResultsController:(RBQFetchedResultsController *)controller
                              withType:(OCTFetchRequestType)type
                             predicate:(NSPredicate *)predicate
{
    OCTSubmanagerObjects *submanager = [RunningContext context].toxManager.objects;
    RBQFetchRequest *fetchRequest = [submanager fetchRequestForType:type withPredicate:predicate];

    [controller updateFetchRequest:fetchRequest sectionNameKeyPath:nil andPeformFetch:YES];
}

@end
