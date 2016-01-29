//
//  CallCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

class CallCoordinator: NSObject {
    private let theme: Theme
    private let submanagerCalls: OCTSubmanagerCalls

    private let navigationControllerStorage: LazyStorage<UINavigationController>

    private let allCallsStorage: LazyStorage<RBQFetchedResultsController>
    private let activeCallsStorage: LazyStorage<RBQFetchedResultsController>
    private let pausedCallsByUserStorage: LazyStorage<RBQFetchedResultsController>

    private var pendingIncomingCall: OCTCall?
    private var activeCallController: AbstractCallController?
    private var activeCall: OCTCall?

    init(theme: Theme, presentingController: UIViewController, submanagerCalls: OCTSubmanagerCalls, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme
        self.submanagerCalls = submanagerCalls

        self.navigationControllerStorage = LazyStorage(createBlock: {
            let navigation = UINavigationController()
            navigation.view.backgroundColor = .clearColor()
            navigation.navigationBarHidden = true
            navigation.modalInPopover = true
            navigation.modalPresentationStyle = .OverCurrentContext

            presentingController.presentViewController(navigation, animated: true, completion: nil)

            UIApplication.sharedApplication().idleTimerDisabled = true

            return navigation
        })

        let allCallsController = submanagerObjects.fetchedResultsControllerForType(.Call)

        // Sort below by pause status so calls that are active with no paused status have priority in getting
        // selected for didRemoveCurrentCall. Since we want to show active(no paused) calls first to the user.
        let activeCallsController = submanagerObjects.fetchedResultsControllerForType(
                .Call,
                predicate: NSPredicate(format:"status == \(OCTCallStatus.Active.rawValue)"),
                sortDescriptors: [RLMSortDescriptor(property: "pausedStatus", ascending: true)])

        let pausedCallsByUserController = submanagerObjects.fetchedResultsControllerForType(
                .Call,
                predicate: NSPredicate(format: "pausedStatus == \(OCTCallPausedStatus.ByUser.rawValue)"))

        self.allCallsStorage = LazyStorage(createBlock: {
            allCallsController.performFetch()
            return allCallsController
        })

        self.activeCallsStorage = LazyStorage(createBlock: {
            activeCallsController.performFetch()
            return activeCallsController
        })

        self.pausedCallsByUserStorage = LazyStorage(createBlock: {
            pausedCallsByUserController.performFetch()
            return pausedCallsByUserController
        })

        super.init()

        submanagerCalls.delegate = self

        // allCallsController.delegate = self
        // activeCallsController.delegate = self
        // pausedCallsByUserController.delegate = self
    }

    deinit {
        removeNavigationController()
    }

    func callToChat(chat: OCTChat, enableVideo: Bool) {
        guard activeCall == nil else {
            assert(false, "We should not be able to make another call yet")
            return
        }

        do {
            let call = try submanagerCalls.callToChat(chat, enableAudio: true, enableVideo: enableVideo)
            changeActiveCallTo(call)
        }
        catch let error as NSError {
            handleErrorWithType(.CallToChat, error: error)
            removeNavigationController()
        }
    }
}

extension CallCoordinator: CoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
        // nothing to do here
    }
}

extension CallCoordinator: OCTSubmanagerCallDelegate {
    func callSubmanager(_: OCTSubmanagerCalls, receiveCall call: OCTCall, audioEnabled: Bool, videoEnabled: Bool) {
        if activeCall != nil {
            notifyAboutIncomingCall(call)
            return
        }

        changeActiveCallTo(call)
    }
}

extension CallCoordinator: RBQFetchedResultsControllerDelegate {
    func controller(
            controller: RBQFetchedResultsController,
            didChangeObject anObject: RBQSafeRealmObject,
            atIndexPath indexPath: NSIndexPath?,
            forChangeType type: RBQFetchedResultsChangeType,
            newIndexPath: NSIndexPath?) {
        switch type {
            case .Update:
                if controller === activeCallsStorage.object {
                    let call = anObject.RLMObject() as! OCTCall

                    if (call.pausedStatus == .None) || (call.pausedStatus == .ByFriend) {
                        updateCurrentCallInterface(call)
                    }
                }
            case .Delete:
                if allCallsStorage.object.fetchedObjects.count == 0 {
                    removeNavigationController()
                    return
                }

                guard controller === allCallsStorage.object else { return }
                guard let activeCall = activeCall else { return }
                guard (anObject.primaryKeyValue as! String) == activeCall.uniqueIdentifier else { return }

                didRemoveCurrentCall()
            case .Insert:
                guard controller === activeCallsStorage.object else { return }
                guard let activeCall = activeCall else { return }
                guard (anObject.primaryKeyValue as! String) != activeCall.uniqueIdentifier else { return }

                // workaround for deadlock in objcTox
                // https://github.com/Antidote-for-Tox/objcTox/issues/51
                performSelector("changeActiveCallTo:", withObject: anObject.RLMObject(), afterDelay: 0)
            case .Move:
                // nop
                break
        }
    }

   func controllerDidChangeContent(controller: RBQFetchedResultsController) {
       if controller === pausedCallsByUserStorage.object {
           if let active = activeCallController as? ActiveCallController {
               active.reloadPausedCalls()
           }
       }
   }
}

private extension CallCoordinator {
    func removeNavigationController() {
        navigationControllerStorage.object.dismissViewControllerAnimated(true, completion: nil)
        navigationControllerStorage.reset()

        UIApplication.sharedApplication().idleTimerDisabled = false
        UIDevice.currentDevice().proximityMonitoringEnabled = false
    }

    func createControllerForCall(call: OCTCall) -> AbstractCallController{
        return AbstractCallController()
    }

    func notifyAboutIncomingCall(call: OCTCall) {
        func guardBlock() {
            log("Unable to take on more calls, incoming call declined")
            _ = try? submanagerCalls.sendCallControl(.Cancel, toCall: call)
        }

        guard pendingIncomingCall == nil else {
            // We only support showing one incoming call at a time. Reject all others
            guardBlock()
            return
        }

        guard let controller = activeCallController else {
            guardBlock()
            return
        }

        guard let active = controller as? ActiveCallController else {
            // For now we reject call if we are in a dialing or ringing state
            guardBlock()
            return
        }

        pendingIncomingCall = call

        let friend: OCTFriend = call.chat.friends.firstObject() as! OCTFriend
        active.createIncomingCallViewForFriend(friend.nickname)
    }

    func updateCurrentCallInterface(call: OCTCall) {
        if activeCall?.uniqueIdentifier != call.uniqueIdentifier {
            changeActiveCallTo(call)
        }

        if (call.status == .Active) {
            let videoEnabled = call.videoIsEnabled || call.friendSendingVideo
            let isVideoController = activeCallController is VideoCallController

            let hasWrongClass = !(activeCallController is ActiveCallController)
            let shouldSwitchToVideo = videoEnabled && !isVideoController
            let shouldSwitchToAudio = !videoEnabled && isVideoController

            if hasWrongClass || shouldSwitchToVideo || shouldSwitchToAudio {
                changeActiveCallTo(call)
            }
        }

        updateActiveControllerIfNeeded(withCall: call)
    }

    func updateActiveControllerIfNeeded(withCall call: OCTCall) {
        // guard let active = activeCallController as? ActiveCallController else {
        //     return
        // }

        // if call.pausedStatus == .ByFriend {
        //     active.friendPausedCall(true)
        // }
        // else {
        //     active.callDuration = call.callDuration
        //     active.friendPausedCall(false)
        // }

        // active.resumeButtonHidden = !(call.pausedStatus & .ByUser)
    }

    func changeActiveCallTo(call: OCTCall?) {
        log("Did update active call \(activeCall)")
        activeCall = call

        guard activeCall != nil else {
            return
        }

        UIDevice.currentDevice().proximityMonitoringEnabled = (activeCall!.status == .Active) || (activeCall!.status == .Dialing)

        activeCallController = createControllerForCall(activeCall!)
        navigationControllerStorage.object.setViewControllers([activeCallController!], animated: false)
    }

    func didRemoveCurrentCall() {

    }
}
