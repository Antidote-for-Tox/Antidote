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

@interface CallsManager () <RBQFetchedResultsControllerDelegate, ActiveCallViewControllerDelegate,
                            ActiveCallViewControllerDataSource, DialingCallViewControllerDelegate,
                            RingingCallViewControllerDelegate>

@property (strong, nonatomic) RBQFetchedResultsController *allCallsController;
@property (strong, nonatomic) RBQFetchedResultsController *allActiveCallsController;
@property (strong, nonatomic) RBQFetchedResultsController *allPausedCallsController;
@property (strong, nonatomic) AbstractCallViewController *currentCallViewController;

@property (strong, nonatomic) UINavigationController *callNavigation;

@property (weak, nonatomic) OCTSubmanagerCalls *manager;

@property (strong, nonatomic) OCTCall *currentCall;
@property (strong, nonatomic) OCTCall *pendingIncomingCall;

@end

@implementation CallsManager

#pragma mark - Lifecycle
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

    predicate = [NSPredicate predicateWithFormat:@"status == %d", OCTCallStatusPaused];
    _allPausedCallsController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeCall
                                                                    predicate:predicate
                                                                     delegate:self];

    _manager = [AppContext sharedContext].profileManager.toxManager.calls;

    _callNavigation = [UINavigationController new];
    _callNavigation.view.backgroundColor = [UIColor clearColor];
    _callNavigation.navigationBarHidden = YES;
    _callNavigation.modalInPopover = YES;
    _callNavigation.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    [[AppContext sharedContext].tabBarController presentViewController:_callNavigation animated:YES completion:nil];

    return self;
}

- (void)dealloc
{
    DDLogVerbose(@"%@, dealloc", self);
    [self.callNavigation dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public

- (void)callToChat:(OCTChat *)chat
{
    DDLogVerbose(@"%@, callToChat:%@", self, chat);

    if (self.currentCall) {
        NSAssert(NO, @"We should not be able to make another call yet");
        return;
    }

    NSError *error;
    OCTCall *call = [self.manager callToChat:chat enableAudio:YES enableVideo:NO error:&error];

    if (! call) {
        DDLogWarn(@"%@, Error callToChat: %@", self, error.localizedFailureReason);
        [[AppContext sharedContext] killCallsManager];
        return;
    }

    [self switchViewControllerForCall:call];
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

    [self switchViewControllerForCall:call];
}

#pragma mark - RBQFetchedResultsControllerDelegate

- (void) controller:(RBQFetchedResultsController *)controller
    didChangeObject:(RBQSafeRealmObject *)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath;
{
    switch (type) {
        case NSFetchedResultsChangeUpdate:
            if (controller == self.allActiveCallsController) {
                OCTCall *call = [anObject RLMObject];
                [self updateDuration:call.callDuration];
            }
            break;
        case NSFetchedResultsChangeDelete: {
            if ([self.allCallsController.fetchedObjects count] == 0) {
                [[AppContext sharedContext] killCallsManager];
                return;
            }

            if ([self onlyPauseCallsLeft]) {
                OCTCall *call = [self.allPausedCallsController.fetchedObjects firstObject];

                // workaround for deadlock in objcTox
                // https://github.com/Antidote-for-Tox/objcTox/issues/51
                [self performSelector:@selector(switchViewControllerForCall:) withObject:call afterDelay:0];
            }
            break;
        }
        case NSFetchedResultsChangeInsert:
            if (controller == self.allActiveCallsController) {
                OCTCall *call = [anObject RLMObject];

                // workaround for deadlock in objcTox
                // https://github.com/Antidote-for-Tox/objcTox/issues/51
                [self performSelector:@selector(switchViewControllerForCall:) withObject:call afterDelay:0];
            }
            break;
        case NSFetchedResultsChangeMove:
            break;
    }
}

- (void)controllerDidChangeContent:(RBQFetchedResultsController *)controller
{
    if (self.allPausedCallsController == controller) {
        if ([self.currentCallViewController isKindOfClass:[ActiveCallViewController class]]) {
            ActiveCallViewController *activeVC = (ActiveCallViewController *)self.currentCallViewController;
            [activeVC reloadPausedCalls];
        }
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

#pragma mark - ActiveCallViewController Delegate

- (void)activeCallDeclineButtonPressed:(ActiveCallViewController *)controller
{
    NSError *error;
    if (! [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:self.currentCall error:&error]) {
        DDLogWarn(@"%@, activeCallDeclineButtonPressed error: %@", self, error.localizedFailureReason);
    }
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
            DDLogWarn(@"%@, sendCallControl error:%@", self, error.localizedFailureReason);
            controller.speakerSelected = YES;
        }
    }
    else {
        if ([self.manager sendCallControl:OCTToxAVCallControlMuteAudio toCall:self.currentCall error:&error]) {
            controller.speakerSelected = YES;
        }
        else if (error.code == OCTToxAVErrorControlInvaldTransition) {
            DDLogWarn(@"%@, sendCallControl error:%@", self, error.localizedFailureReason);
            controller.speakerSelected = NO;
        }
    }
}

- (void)activeCallPauseButtonPressed:(ActiveCallViewController *)controller
{
    NSError *error;
    if (controller.pauseSelected) {
        if ([self.manager sendCallControl:OCTToxAVCallControlResume toCall:self.currentCall error:&error]) {
            controller.pauseSelected = NO;
        }
        else {
            DDLogWarn(@"%@, activeCallPauseButtonPressed:OCTToxAVCallControlResume error: %@", self, error.localizedFailureReason);
        }
    }
    else {
        if ([self.manager sendCallControl:OCTToxAVCallControlPause toCall:self.currentCall error:nil]) {
            controller.pauseSelected = YES;
        }
        else {
            DDLogWarn(@"%@, activeCallPauseButtonPressed:OCTToxAVCallControlPause error: %@", self, error.localizedFailureReason);
        }
    }
}

- (void)activeCallDeclineIncomingCallButtonPressed:(ActiveCallViewController *)controller
{
    NSError *error;
    if (! [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:self.pendingIncomingCall error:&error]) {
        DDLogWarn(@"%@, activeCallDeclineIncomingCallButtonPressed error:%@", self, error.localizedFailureReason);
    }
    self.pendingIncomingCall = nil;
    [controller hideIncomingCallView];
}

- (void)activeCallAnswerIncomingCallButtonPressed:(ActiveCallViewController *)controller
{
    DDLogVerbose(@"%@, activeCallAnswerIncomingCallButtonPressed", self);

    NSError *error;

    if (! [self.manager answerCall:self.pendingIncomingCall enableAudio:YES enableVideo:NO error:&error]) {
        DDLogWarn(@"%@, activeCallAnswerIncomingCallButtonPressed, error: %@", self, error.localizedFailureReason);
    }


    self.pendingIncomingCall = nil;
    [controller hideIncomingCallView];
}

#pragma mark - DialingCallViewController Delegate

- (void)dialingCallDeclineButtonPressed:(DialingCallViewController *)controller
{
    DDLogVerbose(@"%@, dialingCallDeclineButtonPressed", self);

    NSError *error;
    if (! [self.manager sendCallControl:OCTToxAVCallControlCancel
                                 toCall:self.currentCall
                                  error:&error]) {
        DDLogWarn(@"%@: dialingCallDeclineButtonPressed error: %@", self, error.localizedFailureReason);
    }
}

#pragma mark - RingingCallViewController Delegate

- (void)ringingCallAnswerButtonPressed:(RingingCallViewController *)controller
{
    DDLogVerbose(@"%@, ringingCallAnswerButtonPressed", self);

    NSError *error;
    if (! [self.manager answerCall:self.currentCall
                       enableAudio:YES
                       enableVideo:NO error:&error]) {
        DDLogWarn(@"%@, ringingCallAnswerButtonPressed error:%@", self, error.localizedFailureReason);
    }
}

- (void)ringingCallDeclineButtonPressed:(RingingCallViewController *)controller
{
    DDLogVerbose(@"%@, ringingCallDeclineButtonPressed", self);

    NSError *error;

    if (! [self.manager sendCallControl:OCTToxAVCallControlCancel
                                 toCall:self.currentCall
                                  error:&error]) {
        DDLogWarn(@"%@, sendCallControl:OCTToxAVCallControlCancel error:%@", self, error.localizedFailureReason);
    }
}

#pragma mark - ActiveCallViewControllerDataSource

- (NSInteger)activeCallControllerNumberOfPausedCalls:(ActiveCallViewController *)controller
{
    return [self.allPausedCallsController numberOfRowsForSectionIndex:0];
}

- (NSString *)activeCallController:(ActiveCallViewController *)controller pausedCallerNicknameForCallAtIndex:(NSIndexPath *)indexPath
{
    OCTCall *call = [self.allPausedCallsController objectAtIndexPath:indexPath];

    OCTFriend *friend = [call.chat.friends firstObject];

    return friend.nickname;
}

- (NSTimeInterval)activeCallController:(ActiveCallViewController *)controller pauseTimeDurationForCallAtIndex:(NSIndexPath *)indexPath
{
    OCTCall *call = [self.allPausedCallsController objectAtIndexPath:indexPath];

    return call.callDuration;
}

- (void)activeCallController:(ActiveCallViewController *)controller resumePausedCallSelectedAtIndex:(NSIndexPath *)indexPath
{
    OCTCall *call = [self.allPausedCallsController objectAtIndexPath:indexPath];

    [self.manager sendCallControl:OCTToxAVCallControlResume toCall:call error:nil];
}

- (void)activeCallController:(ActiveCallViewController *)controller endPausedCallSelectedAtIndex:(NSIndexPath *)indexPath
{
    OCTCall *call = [self.allPausedCallsController objectAtIndexPath:indexPath];

    [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:call error:nil];
}

#pragma mark - Private

- (void)notifyOfIncomingCall:(OCTCall *)call
{
    if (! [self.currentCallViewController isKindOfClass:[ActiveCallViewController class]]) {
        // For now we reject call if we are in a dialing or ringing state

        NSError *error;
        if (! [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:call error:&error]) {
            DDLogWarn(@"%@, sendCallControl:OCTToxAVCallControlCancel error:%@", self, error.localizedFailureReason);
        }
        return;
    }

    self.pendingIncomingCall = call;

    OCTFriend *friend = [self.pendingIncomingCall.chat.friends firstObject];

    ActiveCallViewController *activeVC = (ActiveCallViewController *)self.currentCallViewController;
    [activeVC createIncomingCallViewForFriend:friend.nickname];
}

- (AbstractCallViewController *)viewControllerForCall:(OCTCall *)call
{
    AbstractCallViewController *viewController;

    OCTFriend *friend = [call.chat.friends firstObject];

    switch (call.status) {
        case OCTCallStatusActive: {
            ActiveCallViewController *activeVC = [ActiveCallViewController new];
            activeVC.delegate = self;
            activeVC.dataSource = self;
            viewController = activeVC;
            break;
        }
        case OCTCallStatusDialing: {
            DialingCallViewController *dialingVC = [DialingCallViewController new];
            dialingVC.delegate = self;
            viewController = dialingVC;
            break;
        }
        case OCTCallStatusRinging: {
            RingingCallViewController *ringingVC = [RingingCallViewController new];
            ringingVC.delegate = self;
            viewController = ringingVC;
            break;
        }
        case OCTCallStatusPaused:
            NSAssert(NO, @"We should not be here yet. Not yet implemented");
            break;
    }

    viewController.nickname = friend.nickname;
    viewController.modalInPopover = YES;
    viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    return viewController;
}

- (void)switchViewControllerForCall:(OCTCall *)call
{
    DDLogVerbose(@"%@, switchViewControllerForCall:%@", self, call);

    if ([self.currentCallViewController isKindOfClass:[ActiveCallViewController class]]) {

        ActiveCallViewController *activeVC = (ActiveCallViewController *)self.currentCallViewController;

        switch (call.status) {
            case OCTCallStatusPaused:
                activeVC.pauseSelected = YES;
                break;
            case OCTCallStatusActive:
                activeVC.pauseSelected = NO;
                break;
            case OCTCallStatusDialing:
            case OCTCallStatusRinging:
                NSAssert(NO, @"We shouldn't be here");
                break;
        }

        OCTFriend *friend = [call.chat.friends firstObject];
        self.currentCallViewController.nickname = friend.nickname;
        self.currentCall = call;

        return;
    }

    AbstractCallViewController *abstractVC = [self viewControllerForCall:call];

    [self.callNavigation setViewControllers:@[abstractVC] animated:YES];

    self.currentCallViewController = abstractVC;

    self.currentCall = call;
}

- (BOOL)onlyPauseCallsLeft
{
    return (([self.allActiveCallsController.fetchedObjects count] == 0) &&
            ([self.allPausedCallsController.fetchedObjects count] != 0));
}

@end
