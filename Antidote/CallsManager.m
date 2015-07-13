//
//  CallsManager.m
//  Antidote
//
//  Created by Chuong Vu on 7/13/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "CallsManager.h"
#import "ProfileManager.h"
#import "OCTSubmanagerCalls.h"
#import "DialingCallViewController.h"
#import "RingingCallViewController.h"
#import "ActiveCallViewController.h"
#import "AppDelegate+Utilities.h"
#import "RBQFetchedResultsController.h"
#import "ProfileManager.h"
#import "Helper.h"
#import "OCTCall.h"
#import "TabBarViewController.h"

@interface CallsManager () <RBQFetchedResultsControllerDelegate>

@property (strong, nonatomic) RBQFetchedResultsController *currentCallController;
@property (strong, nonatomic) RBQFetchedResultsController *allCallsController;
@property (strong, nonatomic) RBQFetchedResultsController *allActiveCallsController;
@property (strong, nonatomic) AbstractCallViewController *currentCallViewController;

@property (weak, nonatomic) OCTSubmanagerCalls *manager;

@property (strong, nonatomic) OCTCall *currentCall;
@property (strong, nonatomic) OCTCall *pendingIncomingCall;

@end

@implementation CallsManager

- (instancetype)init
{
    self = [super self];

    if (! self) {
        return nil;
    }

    _allCallsController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeCall
                                                               delegate:self];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %d", OCTCallStatusActive];
    _allActiveCallsController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeCall
                                                                    predicate:predicate
                                                                     delegate:self];

    _manager = [AppContext sharedContext].profileManager.toxManager.calls;

    return self;
}

- (void)callToChat:(OCTChat *)chat
{
    if (self.currentCall) {
        NSAssert(NO, @"We should not be able to make another call yet");
        return;
    }

    OCTCall *call = [self.manager callToChat:chat enableAudio:YES enableVideo:NO error:nil];

    if (! call) {
        [[AppContext sharedContext] killCallsManager];
    }

    [self dismissAndSwitchViewControllerForCall:call];
}

- (void)handleIncomingCall:(OCTCall *)call
{
    if (self.currentCall) {

        self.pendingIncomingCall = call;

        [self notifyOfIncomingCall];

        return;
    }

    [self dismissAndSwitchViewControllerForCall:call];
}

#pragma mark - RBQFetchedResultsControllerDelegate

- (void) controller:(RBQFetchedResultsController *)controller
    didChangeObject:(RBQSafeRealmObject *)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath;
{

    if (type == NSFetchedResultsChangeDelete) {
        if ([self.allCallsController.fetchedObjects count] == 0) {
            [[AppContext sharedContext] killCallsManager];
        }
    }

    if ((type == NSFetchedResultsChangeInsert) && (controller == self.allActiveCallsController)) {
        OCTCall *call = [anObject RLMObject];
        [self.allActiveCallsController objectAtIndexPath:newIndexPath];

        // workaround for deadlock in objcTox
        // https://github.com/Antidote-for-Tox/objcTox/issues/51
        [self performSelector:@selector(dismissAndSwitchViewControllerForCall:) withObject:call afterDelay:0];
    }
}

- (void)controllerDidChangeContent:(RBQFetchedResultsController *)controller
{
    if (controller == self.currentCallController) {
        self.currentCall = [[self.currentCallController fetchedObjects] firstObject];
        [self updateDuration:self.currentCall.callDuration];
    }
}

#pragma mark - Updates to Current Call

- (void)updateDuration:(NSTimeInterval)duration
{
    self.currentCallViewController.callDuration = duration;
}

#pragma mark - AbstractCallViewControllerDelegate

- (void)dismissCurrentCall
{
    [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:self.currentCall error:nil];
    [self.currentCallViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)callAccept
{
    [self.manager answerCall:self.currentCall enableAudio:YES enableVideo:NO error:nil];
}

- (BOOL)sendCallControl:(OCTToxAVCallControl)control error:(NSError **)error;
{
    return [self.manager sendCallControl:control toCall:self.currentCall error:error];
}

- (void)otherCallAccept:(BOOL)accept
{
    if (! [self.manager answerCall:self.pendingIncomingCall enableAudio:YES enableVideo:NO error:nil]) {
        return;
    }

    self.currentCall = self.pendingIncomingCall;

    self.pendingIncomingCall = nil;

    [self dismissAndSwitchViewControllerForCall:self.currentCall];
}

- (void)setEnableMicrophone:(BOOL)enableMicrophone
{
    self.manager.enableMicrophone = enableMicrophone;
}

- (BOOL)enableMicrophone
{
    return self.manager.enableMicrophone;
}

#pragma mark - Private

- (void)notifyOfIncomingCall
{
    OCTFriend *friend = [self.pendingIncomingCall.chat.friends firstObject];

    [self.currentCallViewController incomingCallFromFriend:friend.nickname];
}

- (void)dealloc
{
    [self.currentCallViewController dismissViewControllerAnimated:YES completion:nil];
}

- (AbstractCallViewController *)viewControllerForCall:(OCTCall *)call
{
    AbstractCallViewController *viewController;

    OCTFriend *friend = [call.chat.friends firstObject];

    switch (call.status) {
        case OCTCallStatusActive:
            viewController = [[ActiveCallViewController alloc] initWithCallerNickname:friend.nickname];
            break;
        case OCTCallStatusDialing:
            viewController = [[DialingCallViewController alloc] initWithCallerNickname:friend.nickname];
            break;
        case OCTCallStatusRinging:
            viewController = [[RingingCallViewController alloc] initWithCallerNickname:friend.nickname];
            break;
        case OCTCallStatusPaused:
            NSAssert(NO, @"We should not be here yet. Not yet implemented");
            break;
    }

    viewController.modalInPopover = YES;
    viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    viewController.delegate = self;

    return viewController;
}

- (void)dismissAndSwitchViewControllerForCall:(OCTCall *)call
{
    [self.currentCallViewController dismissViewControllerAnimated:NO completion:nil];

    AbstractCallViewController *abstractVC = [self viewControllerForCall:call];

    TabBarViewController *tabBarVC = (TabBarViewController *)[AppContext sharedContext].tabBarController;
    [tabBarVC presentViewController:abstractVC
                           animated:YES
                         completion:nil];

    NSPredicate *predicateForCurrentCall = [NSPredicate predicateWithFormat:@"uniqueIdentifier == %@",
                                            call.uniqueIdentifier];

    self.currentCallController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeCall
                                                                     predicate:predicateForCurrentCall
                                                                      delegate:self];

    self.currentCallViewController = abstractVC;
    self.currentCall = call;
}
@end
