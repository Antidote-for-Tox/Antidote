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
#import "AbstractCallViewController.h"

@interface CallsManager () <RBQFetchedResultsControllerDelegate, ActiveCallViewControllerDelegate, DialingCallViewControllerDelegate, RingingCallViewControllerDelegate>

@property (strong, nonatomic) RBQFetchedResultsController *currentCallController;
@property (strong, nonatomic) RBQFetchedResultsController *allCallsController;
@property (strong, nonatomic) RBQFetchedResultsController *allActiveCallsController;
@property (strong, nonatomic) RBQFetchedResultsController *allPausedCallsController;
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

#pragma mark - Public

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
    if (self.currentCall && self.pendingIncomingCall) {
        // We only support showing one incoming call at a time. Reject all others
        [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:call error:nil];
    }

    if (self.currentCall) {
        [self notifyOfIncomingCall:call];
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

        // workaround for deadlock in objcTox
        // https://github.com/Antidote-for-Tox/objcTox/issues/51
        [self performSelector:@selector(dismissAndSwitchToActiveViewControllerForCall:) withObject:call afterDelay:0];
    }
}

- (void)controllerDidChangeContent:(RBQFetchedResultsController *)controller
{
    if (controller == self.allActiveCallsController) {
        self.currentCall = [[self.allActiveCallsController fetchedObjects] firstObject];
        [self updateDuration:self.currentCall.callDuration];
    }
}

#pragma mark - Updates to Current Call

- (void)updateDuration:(NSTimeInterval)duration
{
    if ([self.currentCallViewController isKindOfClass:[ActiveCallViewController class]]) {
        ActiveCallViewController *activeVC = (ActiveCallViewController *)self.currentCallViewController;
        activeVC.callDuration = duration;
    }
}

- (void)setEnableMicrophone:(BOOL)enableMicrophone
{
    self.manager.enableMicrophone = enableMicrophone;
}

- (BOOL)enableMicrophone
{
    return self.manager.enableMicrophone;
}

#pragma mark - ActiveCallViewController Delegate

- (void)activeCallDeclineButtonPressed:(ActiveCallViewController *)controller
{
    [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:self.currentCall error:nil];
}

- (void)activeCallMicButtonPressed:(ActiveCallViewController *)controller
{
    BOOL enable = controller.micSelected;
    self.manager.enableMicrophone = enable;
    controller.micSelected = ! enable;
}

- (void)activeCallSpeakerButtonPressed:(ActiveCallViewController *)controller
{
    NSError *error;

    if (controller.speakerSelected) {
        if ([self.manager sendCallControl:OCTToxAVCallControlUnmuteAudio toCall:self.currentCall error:&error]) {
            controller.speakerSelected = NO;
        }
        else if (error.code == OCTToxAVErrorControlInvaldTransition) {
            controller.speakerSelected = YES;
        }
    }
    else {
        if ([self.manager sendCallControl:OCTToxAVCallControlMuteAudio toCall:self.currentCall error:&error]) {
            controller.speakerSelected = YES;
        }
        else if (error.code == OCTToxAVErrorControlInvaldTransition) {
            controller.speakerSelected = NO;
        }
    }
}

- (void)activeCallDeclineIncomingCallButtonPressed:(ActiveCallViewController *)controller
{
    [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:self.pendingIncomingCall error:nil];
    self.pendingIncomingCall = nil;
    controller.incomingCallCallerName = nil;
    controller.createIncomingCallView = NO;
}

- (void)activeCallAnswerIncomingCallButtonPressed:(ActiveCallViewController *)controller
{
    [self.manager answerCall:self.pendingIncomingCall enableAudio:YES enableVideo:NO error:nil];
    self.pendingIncomingCall = nil;
    controller.incomingCallCallerName = nil;
    controller.createIncomingCallView = NO;
}

- (void)activeCallPausedCallSelectedAtIndex:(NSUInteger)index controller:(ActiveCallViewController *)controller
{
    // grab paused call from RBQ index and resume call.
}

#pragma mark - DialingCallViewController Delegate

- (void)dialingCallDeclineButtonPressed:(DialingCallViewController *)controller
{
    [self.manager sendCallControl:OCTToxAVCallControlCancel
                           toCall:self.currentCall
                            error:nil];
}

#pragma mark - RingingCallViewController Delegate

- (void)ringingCallAnswerButtonPressed:(RingingCallViewController *)controller
{
    [self.manager answerCall:self.currentCall
                 enableAudio:YES
                 enableVideo:NO error:nil];
}

- (void)ringingCallDeclineButtonPressed:(RingingCallViewController *)controller
{
    [self.manager sendCallControl:OCTToxAVCallControlCancel
                           toCall:self.currentCall
                            error:nil];
}

#pragma mark - Private

- (void)notifyOfIncomingCall:(OCTCall *)call
{
    if (! [self.currentCallViewController isKindOfClass:[ActiveCallViewController class]]) {
        // For now we reject call if we are in a dialing or ringing state
        [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:call error:nil];
        return;
    }

    self.pendingIncomingCall = call;

    OCTFriend *friend = [self.pendingIncomingCall.chat.friends firstObject];

    ActiveCallViewController *activeVC = (ActiveCallViewController *)self.currentCallViewController;
    activeVC.incomingCallCallerName = friend.nickname;
    activeVC.createIncomingCallView = YES;
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
            viewController = [ActiveCallViewController new];
            break;
        case OCTCallStatusDialing:
            viewController = [DialingCallViewController new];
            break;
        case OCTCallStatusRinging:
            viewController = [RingingCallViewController new];
            break;
        case OCTCallStatusPaused:
            NSAssert(NO, @"We should not be here yet. Not yet implemented");
            break;
    }

    viewController.nickname = friend.nickname;
    viewController.modalInPopover = YES;
    viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    viewController.delegate = self;

    return viewController;
}

- (void)dismissAndSwitchViewControllerForCall:(OCTCall *)call
{
    AbstractCallViewController *abstractVC = [self viewControllerForCall:call];

    TabBarViewController *tabBarVC = (TabBarViewController *)[AppContext sharedContext].tabBarController;

    if ([tabBarVC presentedViewController]) {
        [self.currentCallViewController dismissViewControllerAnimated:NO completion:^{
            [tabBarVC presentViewController:abstractVC
                                   animated:YES
                                 completion:nil];
        }];
    }
    else {
        [tabBarVC presentViewController:abstractVC
                               animated:YES
                             completion:nil];
    }

    NSPredicate *predicateForCurrentCall = [NSPredicate predicateWithFormat:@"uniqueIdentifier == %@",
                                            call.uniqueIdentifier];

    self.currentCallController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeCall
                                                                     predicate:predicateForCurrentCall
                                                                      delegate:self];

    self.currentCallViewController = abstractVC;
    self.currentCall = call;
}

- (void)dismissAndSwitchToActiveViewControllerForCall:(OCTCall *)call
{
    if ([self.currentCallViewController isKindOfClass:[ActiveCallViewController class]]) {
        OCTFriend *friend = [call.chat.friends firstObject];
        self.currentCallViewController.nickname = friend.nickname;

        NSPredicate *predicateForCurrentCall = [NSPredicate predicateWithFormat:@"uniqueIdentifier == %@",
                                                call.uniqueIdentifier];

        self.currentCallController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeCall
                                                                         predicate:predicateForCurrentCall
                                                                          delegate:self];

        self.currentCall = call;
    }
    else {
        [self dismissAndSwitchViewControllerForCall:call];
    }
}

@end
