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
#import "RingTonePlayer.h"

#define LOG_IDENTIFIER self

@interface CallsManager () <RBQFetchedResultsControllerDelegate, ActiveCallViewControllerDelegate,
                            ActiveCallViewControllerDataSource, DialingCallViewControllerDelegate,
                            RingingCallViewControllerDelegate>

@property (strong, nonatomic) RBQFetchedResultsController *allCallsController;
@property (strong, nonatomic) RBQFetchedResultsController *allActiveCallsController;
@property (strong, nonatomic) RBQFetchedResultsController *allPausedCallsByUserController;
@property (strong, nonatomic) AbstractCallViewController *currentCallViewController;

@property (strong, nonatomic) UINavigationController *callNavigation;

@property (weak, nonatomic) OCTSubmanagerCalls *manager;

@property (strong, nonatomic) RBQSafeRealmObject *currentCall;
@property (strong, nonatomic) OCTCall *pendingIncomingCall;

@property (strong, nonatomic) RingTonePlayer *ringTonePlayer;

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

    // Sort below by pause status so calls that are active with no paused status have priority in getting
    // selected for didRemoveCurrentCall. Since we want to show active(no paused) calls first to the user.
    NSArray *sortDescriptors = @[
        [RLMSortDescriptor sortDescriptorWithProperty:@"pausedStatus" ascending:YES]
    ];
    _allActiveCallsController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeCall
                                                                    predicate:predicate
                                                              sortDescriptors:sortDescriptors
                                                                     delegate:self];

    predicate = [NSPredicate predicateWithFormat:@"pausedStatus == %d", OCTCallPausedStatusByUser];
    _allPausedCallsByUserController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeCall
                                                                          predicate:predicate
                                                                           delegate:self];

    _manager = [AppContext sharedContext].profileManager.toxManager.calls;

    _callNavigation = [UINavigationController new];
    _callNavigation.view.backgroundColor = [UIColor clearColor];
    _callNavigation.navigationBarHidden = YES;
    _callNavigation.modalInPopover = YES;
    _callNavigation.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    [[AppContext sharedContext].tabBarController presentViewController:_callNavigation animated:YES completion:nil];

    _ringTonePlayer = [RingTonePlayer new];

    return self;
}

- (void)dealloc
{
    AALogVerbose();
    [self.callNavigation dismissViewControllerAnimated:YES completion:nil];
    [self.ringTonePlayer stopPlayingSound];

    UIDevice *currentDevice = [UIDevice currentDevice];
    currentDevice.proximityMonitoringEnabled = NO;

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

    [self.ringTonePlayer playRingBackTone];
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

    [self.ringTonePlayer playRingTone];
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
                if (call.pausedStatus == OCTCallPausedStatusNone) {
                    [self updateCurrentCallInterface:[anObject RLMObject]];
                }
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

                [self.ringTonePlayer stopPlayingSound];

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
    if (self.allPausedCallsByUserController == controller) {
        if ([self.currentCallViewController isKindOfClass:[ActiveCallViewController class]]) {
            ActiveCallViewController *activeVC = (ActiveCallViewController *)self.currentCallViewController;
            [activeVC reloadPausedCalls];
        }
    }
}
#pragma mark - Updates to Current Call

- (void)updateCurrentCallInterface:(OCTCall *)call
{
    if (! [self.currentCall.primaryKeyValue isEqualToString:call.uniqueIdentifier]) {
        [self switchViewControllerForCall:call];
    }

    if ([self.currentCallViewController isKindOfClass:[ActiveCallViewController class]]) {
        ActiveCallViewController *activeVC = (ActiveCallViewController *)self.currentCallViewController;
        activeVC.callDuration = call.callDuration;
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
    BOOL selected = ! controller.speakerSelected;

    NSError *error;
    if (! [self.manager routeAudioToSpeaker:selected error:&error]) {
        AALogWarn(@"Error:%@", error);
    }
    else {
        controller.speakerSelected = selected;
    }

    UIDevice *currentDevice = [UIDevice currentDevice];
    currentDevice.proximityMonitoringEnabled = ! controller.speakerSelected;
}

- (void)activeCallResumeButtonPressed:(ActiveCallViewController *)controller
{
    AALogVerbose(@"%@", controller);

    OCTCall *call = [self.currentCall RLMObject];

    NSError *error;

    if (! [self.manager sendCallControl:OCTToxAVCallControlResume toCall:call error:&error]) {
        AALogWarn(@"%@", error);
    }
    ;

    [controller hideResumeButton];
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

    [self.ringTonePlayer stopPlayingSound];

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

    [self.ringTonePlayer stopPlayingSound];

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

    [self.ringTonePlayer stopPlayingSound];

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
    return [self.allPausedCallsByUserController numberOfRowsForSectionIndex:0];
}

- (NSString *)activeCallController:(ActiveCallViewController *)controller pausedCallerNicknameForCallAtIndex:(NSIndexPath *)indexPath
{
    OCTCall *call = [self.allPausedCallsByUserController objectAtIndexPath:indexPath];

    OCTFriend *friend = [call.chat.friends firstObject];

    return friend.nickname;
}

- (NSDate *)activeCallController:(ActiveCallViewController *)controller pauseDateForCallAtIndex:(NSIndexPath *)indexPath
{
    OCTCall *call = [self.allPausedCallsByUserController objectAtIndexPath:indexPath];

    return [call onHoldDate];
}

- (void)activeCallController:(ActiveCallViewController *)controller resumePausedCallSelectedAtIndex:(NSIndexPath *)indexPath
{
    OCTCall *call = [self.allPausedCallsByUserController objectAtIndexPath:indexPath];

    AALogVerbose(@"%@ call:%@", controller, call);

    NSError *error;
    if (! [self.manager sendCallControl:OCTToxAVCallControlResume toCall:call error:&error]) {
        AALogWarn(@"%@", error);
    }

}

- (void)activeCallController:(ActiveCallViewController *)controller endPausedCallSelectedAtIndex:(NSIndexPath *)indexPath
{
    OCTCall *call = [self.allPausedCallsByUserController objectAtIndexPath:indexPath];

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

- (AbstractCallViewController *)createViewControllerForCall:(OCTCall *)call
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
    }

    viewController.nickname = friend.nickname;
    viewController.modalInPopover = YES;
    viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    return viewController;
}

- (void)switchViewControllerForCall:(OCTCall *)call
{
    AALogVerbose(@"%@", call);

    UIDevice *currentDevice = [UIDevice currentDevice];
    currentDevice.proximityMonitoringEnabled = (call.status == OCTCallStatusActive ||
                                                call.status == OCTCallStatusDialing);

    if ([self.currentCallViewController isKindOfClass:[ActiveCallViewController class]] &&
        (call.status == OCTCallStatusActive) ) {

        ActiveCallViewController *activeVC = (ActiveCallViewController *)self.currentCallViewController;

        if (call.pausedStatus == OCTCallPausedStatusByUser) {
            [activeVC showResumeButton];
        }

        OCTFriend *friend = [call.chat.friends firstObject];
        self.currentCallViewController.nickname = friend.nickname;
        self.currentCall = [RBQSafeRealmObject safeObjectFromObject:call];

        return;
    }

    AbstractCallViewController *abstractVC = [self createViewControllerForCall:call];

    [self.callNavigation setViewControllers:@[abstractVC] animated:YES];

    self.currentCallViewController = abstractVC;

    self.currentCall = [RBQSafeRealmObject safeObjectFromObject:call];
}

- (void)didRemoveCurrentCall
{
    OCTCall *call = [self.allActiveCallsController.fetchedObjects firstObject] ?:
                    [self.allCallsController.fetchedObjects firstObject];

    if (! call) {
        return;
    }

    // workaround for deadlock in objcTox
    // https://github.com/Antidote-for-Tox/objcTox/issues/51
    [self performSelector:@selector(switchViewControllerForCall:) withObject:call afterDelay:0];
}


@end
