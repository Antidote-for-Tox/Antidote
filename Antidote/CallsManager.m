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

#define LOG_IDENTIFIER self

@interface CallsManager () <RBQFetchedResultsControllerDelegate, ActiveCallViewControllerDelegate,
                            ActiveCallViewControllerDataSource, DialingCallViewControllerDelegate,
                            RingingCallViewControllerDelegate>

@property (strong, nonatomic) RBQFetchedResultsController *allCallsController;
@property (strong, nonatomic) RBQFetchedResultsController *allActiveCallsController;
@property (strong, nonatomic) RBQFetchedResultsController *allPausedCallsController;
@property (strong, nonatomic) AbstractCallViewController *currentCallViewController;

@property (strong, nonatomic) UINavigationController *callNavigation;

@property (weak, nonatomic) OCTSubmanagerCalls *manager;

@property (strong, nonatomic) RBQSafeRealmObject *currentCall;
@property (strong, nonatomic) OCTCall *pendingIncomingCall;

@end

@implementation CallsManager

#pragma mark - Lifecycle
- (instancetype)init
{
    AALogVerbose();
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
    AALogVerbose();
    [self.callNavigation dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public

- (void)callToChat:(OCTChat *)chat
{
    AALogVerbose(@"%@", chat);

    if (self.currentCall) {
        NSAssert(NO, @"We should not be able to make another call yet");
        return;
    }

    NSError *error;
    OCTCall *call = [self.manager callToChat:chat enableAudio:YES enableVideo:NO error:&error];

    if (! call) {
        AALogWarn(@"%@", error);
        [[AppContext sharedContext] killCallsManager];
        return;
    }

    [self switchViewControllerForCall:call];
}

- (void)handleIncomingCall:(OCTCall *)call
{
    AALogVerbose(@"%@", call);

    if (self.currentCall && self.pendingIncomingCall) {
        // We only support showing one incoming call at a time. Reject all others
        [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:call error:nil];
        AALogVerbose(@"Unable to take on more calls, incoming call declined");
        return;
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

            if (controller == self.allCallsController) {

                if ([anObject.primaryKeyValue isEqualToString:self.currentCall.primaryKeyValue]) {
                    [self didRemoveCurrentCall];
                }
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
    AALogVerbose(@"%@", controller);

    OCTCall *call = [self.currentCall RLMObject];

    NSError *error;
    if (! [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:call error:&error]) {
        AALogWarn(@"%@", error);
    }
}

- (void)activeCallMicButtonPressed:(ActiveCallViewController *)controller
{
    AALogVerbose(@"%@", controller);

    BOOL enable = controller.micSelected;
    self.manager.enableMicrophone = enable;
    controller.micSelected = ! enable;
}

- (void)activeCallSpeakerButtonPressed:(ActiveCallViewController *)controller
{
    AALogVerbose(@"%@", controller);

    OCTCall *call = [self.currentCall RLMObject];

    NSError *error;

    OCTToxAVCallControl control = (controller.speakerSelected) ? OCTToxAVCallControlUnmuteAudio : OCTToxAVCallControlMuteAudio;

    if ([self.manager sendCallControl:control toCall:call error:&error]) {
        controller.speakerSelected = ! controller.speakerSelected;
    }
    else {
        AALogWarn(@"Error: %@", error);
    }
}

- (void)activeCallPauseButtonPressed:(ActiveCallViewController *)controller
{
    AALogVerbose(@"%@", controller);

    OCTCall *call = [self.currentCall RLMObject];

    NSError *error;
    OCTToxAVCallControl control = controller.pauseSelected ? OCTToxAVCallControlResume : OCTToxAVCallControlPause;

    BOOL result = [self.manager sendCallControl:control toCall:call error:&error];

    if (result) {
        controller.pauseSelected = ! controller.pauseSelected;
    }
    else {
        AALogWarn(@"%@", error);
    }
}

- (void)activeCallDeclineIncomingCallButtonPressed:(ActiveCallViewController *)controller
{
    AALogVerbose(@"%@", controller);

    NSError *error;
    if (! [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:self.pendingIncomingCall error:&error]) {
        AALogWarn(@"%@", error);
    }
    self.pendingIncomingCall = nil;
    [controller hideIncomingCallView];
}

- (void)activeCallAnswerIncomingCallButtonPressed:(ActiveCallViewController *)controller
{
    AALogVerbose(@"%@", controller);

    NSError *error;

    if (! [self.manager answerCall:self.pendingIncomingCall enableAudio:YES enableVideo:NO error:&error]) {
        AALogWarn(@"%@", error);
    }


    self.pendingIncomingCall = nil;
    [controller hideIncomingCallView];
}

#pragma mark - DialingCallViewController Delegate

- (void)dialingCallDeclineButtonPressed:(DialingCallViewController *)controller
{
    AALogVerbose(@"%@", controller);

    OCTCall *call = [self.currentCall RLMObject];

    NSError *error;
    if (! [self.manager sendCallControl:OCTToxAVCallControlCancel
                                 toCall:call
                                  error:&error]) {
        AALogWarn(@"%@", error);
    }
}

#pragma mark - RingingCallViewController Delegate

- (void)ringingCallAnswerButtonPressed:(RingingCallViewController *)controller
{
    AALogVerbose(@"%@", controller);

    OCTCall *call = [self.currentCall RLMObject];

    NSError *error;
    if (! [self.manager answerCall:call
                       enableAudio:YES
                       enableVideo:NO error:&error]) {
        AALogWarn(@"%@", error);
    }
}

- (void)ringingCallDeclineButtonPressed:(RingingCallViewController *)controller
{
    AALogVerbose(@"%@", controller);

    OCTCall *call = [self.currentCall RLMObject];

    NSError *error;

    if (! [self.manager sendCallControl:OCTToxAVCallControlCancel
                                 toCall:call
                                  error:&error]) {
        AALogWarn(@"%@", error);
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

- (NSDate *)activeCallController:(ActiveCallViewController *)controller pauseDateForCallAtIndex:(NSIndexPath *)indexPath
{
    OCTCall *call = [self.allPausedCallsController objectAtIndexPath:indexPath];

    return [call onHoldDate];
}

- (void)activeCallController:(ActiveCallViewController *)controller resumePausedCallSelectedAtIndex:(NSIndexPath *)indexPath
{
    OCTCall *call = [self.allPausedCallsController objectAtIndexPath:indexPath];

    AALogVerbose(@"%@ call:%@", controller, call);

    NSError *error;
    if (! [self.manager sendCallControl:OCTToxAVCallControlResume toCall:call error:&error]) {
        AALogWarn(@"%@", error);
    }

}

- (void)activeCallController:(ActiveCallViewController *)controller endPausedCallSelectedAtIndex:(NSIndexPath *)indexPath
{
    OCTCall *call = [self.allPausedCallsController objectAtIndexPath:indexPath];

    AALogVerbose(@"%@ call:%@", controller, call);

    NSError *error;
    if (! [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:call error:&error]) {
        AALogWarn(@"%@", error);
    }
}

#pragma mark - Private

- (void)notifyOfIncomingCall:(OCTCall *)call
{
    if (! [self.currentCallViewController isKindOfClass:[ActiveCallViewController class]]) {
        // For now we reject call if we are in a dialing or ringing state

        NSError *error;
        if (! [self.manager sendCallControl:OCTToxAVCallControlCancel toCall:call error:&error]) {
            AALogWarn(@"%@", error);
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
    AALogVerbose(@"%@", call);

    if ([self isCurrentViewControllerReusableForCurrentCall:call]) {

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
        self.currentCall = [RBQSafeRealmObject safeObjectFromObject:call];

        return;
    }

    AbstractCallViewController *abstractVC = [self viewControllerForCall:call];

    [self.callNavigation setViewControllers:@[abstractVC] animated:YES];

    self.currentCallViewController = abstractVC;

    self.currentCall = [RBQSafeRealmObject safeObjectFromObject:call];
}

- (void)didRemoveCurrentCall
{
    OCTCall *call = [self.allPausedCallsController.fetchedObjects firstObject] ?:
                    [self.allCallsController.fetchedObjects firstObject];

    if (! call) {
        return;
    }

    // workaround for deadlock in objcTox
    // https://github.com/Antidote-for-Tox/objcTox/issues/51
    [self performSelector:@selector(switchViewControllerForCall:) withObject:call afterDelay:0];
}

- (BOOL)isCurrentViewControllerReusableForCurrentCall:(OCTCall *)call
{
    if (! ((call.status == OCTCallStatusActive) || (call.status == OCTCallStatusPaused))) {
        return NO;
    }

    if ([self.currentCallViewController isKindOfClass:[ActiveCallViewController class]]) {
        return YES;
    }

    return NO;
}

@end
