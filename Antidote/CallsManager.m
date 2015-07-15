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
    [self.callNavigation dismissViewControllerAnimated:YES completion:nil];
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
    if (type == NSFetchedResultsChangeUpdate) {
        if (controller == self.allActiveCallsController) {
            OCTCall *call = [anObject RLMObject];
            [self updateDuration:call.callDuration];
        }
    }

    if (type == NSFetchedResultsChangeDelete) {
        if ([self.allCallsController.fetchedObjects count] == 0) {
            [[AppContext sharedContext] killCallsManager];
        }

        if ([self onlyPauseCallsLeft]) {
            OCTCall *call = [self.allPausedCallsController.fetchedObjects firstObject];

            // workaround for deadlock in objcTox
            // https://github.com/Antidote-for-Tox/objcTox/issues/51
            [self performSelector:@selector(dismissAndSwitchToActiveViewControllerForCall:) withObject:call afterDelay:0];
        }
    }

    if ((type == NSFetchedResultsChangeInsert) && (controller == self.allActiveCallsController)) {
        OCTCall *call = [anObject RLMObject];

        // workaround for deadlock in objcTox
        // https://github.com/Antidote-for-Tox/objcTox/issues/51
        [self performSelector:@selector(dismissAndSwitchToActiveViewControllerForCall:) withObject:call afterDelay:0];
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

- (void)activeCallPauseButtonPressed:(ActiveCallViewController *)controller
{
    if (controller.pauseSelected) {
        if ([self.manager sendCallControl:OCTToxAVCallControlResume toCall:self.currentCall error:nil]) {
            controller.pauseSelected = NO;
        }
    }
    else {
        if ([self.manager sendCallControl:OCTToxAVCallControlPause toCall:self.currentCall error:nil]) {
            controller.pauseSelected = YES;
        }
    }
}

- (void)activeCallDeclineIncomingCallButtonPressed:(ActiveCallViewController *)controller
{
    [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:self.pendingIncomingCall error:nil];
    self.pendingIncomingCall = nil;
    [controller hideIncomingCallView];
}

- (void)activeCallAnswerIncomingCallButtonPressed:(ActiveCallViewController *)controller
{
    [self.manager answerCall:self.pendingIncomingCall enableAudio:YES enableVideo:NO error:nil];
    self.pendingIncomingCall = nil;
    [controller hideIncomingCallView];
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

- (void)dismissAndSwitchViewControllerForCall:(OCTCall *)call
{
    AbstractCallViewController *abstractVC = [self viewControllerForCall:call];

    [self.callNavigation setViewControllers:@[abstractVC] animated:YES];

    self.currentCallViewController = abstractVC;

    self.currentCall = call;
}

- (void)dismissAndSwitchToActiveViewControllerForCall:(OCTCall *)call
{
    if ([self.currentCallViewController isKindOfClass:[ActiveCallViewController class]]) {

        if (call.status == OCTCallStatusPaused) {
            ActiveCallViewController *activeVC = (ActiveCallViewController *)self.currentCallViewController;
            activeVC.pauseSelected = YES;
        }

        OCTFriend *friend = [call.chat.friends firstObject];
        self.currentCallViewController.nickname = friend.nickname;
        self.currentCall = call;
    }
    else {
        [self dismissAndSwitchViewControllerForCall:call];
    }
}

- (BOOL)onlyPauseCallsLeft
{
    return (([self.allActiveCallsController.fetchedObjects count] == 0) &&
            ([self.allPausedCallsController.fetchedObjects count] != 0));
}

@end
