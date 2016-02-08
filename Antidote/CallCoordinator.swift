//
//  CallCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

private struct Constants {
    static let DeclineAfterInterval = 1.5
}

private struct ActiveCall {
    private let call: OCTCall
    private let navigation: UINavigationController
    private let callController: RBQFetchedResultsController
}

class CallCoordinator: NSObject {
    private let theme: Theme
    private weak var presentingController: UIViewController!
    private weak var submanagerCalls: OCTSubmanagerCalls!
    private weak var submanagerObjects: OCTSubmanagerObjects!

    private var activeCall: ActiveCall?

    init(theme: Theme, presentingController: UIViewController, submanagerCalls: OCTSubmanagerCalls, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme
        self.presentingController = presentingController
        self.submanagerCalls = submanagerCalls
        self.submanagerObjects = submanagerObjects

        super.init()

        submanagerCalls.delegate = self
    }

    func callToChat(chat: OCTChat, enableVideo: Bool) {
        // do {
        //     let call = try submanagerCalls.callToChat(chat, enableAudio: true, enableVideo: enableVideo)
        //     let friend = chat.friends.lastObject() as! OCTFriend

        //     let controller = CallActiveController(theme: theme, callerName: friend.nickname)
        //     controller.delegate = self

        //     startActiveCallWithCall(call, controller: controller)
        // }
        // catch let error as NSError {

        // }
    }
}

extension CallCoordinator: CoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
    }
}

extension CallCoordinator: OCTSubmanagerCallDelegate {
    func callSubmanager(callSubmanager: OCTSubmanagerCalls!, receiveCall call: OCTCall!, audioEnabled: Bool, videoEnabled: Bool) {
        guard activeCall == nil else {
            // Currently we support only one call at a time
            _ = try? submanagerCalls.sendCallControl(.Cancel, toCall: call)
            return
        }

        let controller = CallIncomingController(theme: theme, callerName: call.caller.nickname)
        controller.delegate = self

        startActiveCallWithCall(call, controller: controller)
    }
}

extension CallCoordinator: CallIncomingControllerDelegate {
    func callIncomingControllerDecline(controller: CallIncomingController) {
        declineCall(callWasRemoved: false)
    }

    func callIncomingControllerAnswerAudio(controller: CallIncomingController) {
        answerCallWithIncomingController(controller, enableVideo: false)
    }

    func callIncomingControllerAnswerVideo(controller: CallIncomingController) {
        answerCallWithIncomingController(controller, enableVideo: true)
    }
}

extension CallCoordinator: CallActiveControllerDelegate {
    func callActiveController(controller: CallActiveController, mute: Bool) {
        submanagerCalls.enableMicrophone = !mute
    }

    func callActiveController(controller: CallActiveController, speaker: Bool) {
        do {
            try submanagerCalls.routeAudioToSpeaker(speaker)
        }
        catch {
            handleErrorWithType(.RouteAudioToSpeaker)
            controller.speaker = !speaker
        }
    }

    func callActiveController(controller: CallActiveController, outgoingVideo: Bool) {
        guard let activeCall = activeCall else {
            assert(false, "This method should be called only if active call is non-nil")
            return
        }

        do {
            try submanagerCalls.enableVideoSending(outgoingVideo, forCall: activeCall.call)
        }
        catch {
            handleErrorWithType(.EnableVideoSending)
            controller.outgoingVideo = !outgoingVideo
        }
    }

    func callActiveControllerDecline(controller: CallActiveController) {
        declineCall(callWasRemoved: false)
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
            case .Insert:
                break
            case .Move:
                break
            case .Delete:
                declineCall(callWasRemoved: true)
            case .Update:
                activeCallWasUpdated()
        }
    }
}

private extension CallCoordinator {
    func declineCall(callWasRemoved wasRemoved: Bool) {
        guard let activeCall = activeCall else {
            assert(false, "This method should be called only if active call is non-nil")
            return
        }

        if !wasRemoved {
            _ = try? submanagerCalls.sendCallControl(.Cancel, toCall: activeCall.call)
        }

        if let controller = activeCall.navigation.topViewController as? CallBaseController {
            controller.prepareForRemoval()
        }

        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Constants.DeclineAfterInterval * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            self?.presentingController.dismissViewControllerAnimated(true, completion: nil)
            self?.activeCall = nil
        }
    }

    func startActiveCallWithCall(call: OCTCall, controller: CallBaseController) {
        guard activeCall == nil else {
            assert(false, "This method should be called only if there is no active call")
            return
        }

        let navigation = UINavigationController(rootViewController: controller)
        navigation.modalPresentationStyle = .OverCurrentContext
        navigation.navigationBarHidden = true
        navigation.modalTransitionStyle = .CrossDissolve

        let predicate = NSPredicate(format: "uniqueIdentifier == %@", call.uniqueIdentifier)
        let callController = submanagerObjects.fetchedResultsControllerForType(.Call, predicate: predicate)
        callController.delegate = self
        callController.performFetch()

        presentingController.presentViewController(navigation, animated: true, completion: nil)

        activeCall = ActiveCall(call: call, navigation: navigation, callController: callController)
    }

    func answerCallWithIncomingController(controller: CallIncomingController, enableVideo: Bool) {
        guard let activeCall = activeCall else {
            assert(false, "This method should be called only if active call is non-nil")
            return
        }

        guard activeCall.call.status == .Ringing else {
            assert(false, "Call status should be .Ringing")
            return
        }

        do {
            try submanagerCalls.answerCall(activeCall.call, enableAudio: true, enableVideo: enableVideo)
        }
        catch let error as NSError {
            handleErrorWithType(.AnswerCall, error: error)

            declineCall(callWasRemoved: false)
        }
    }

    func activeCallWasUpdated() {
        guard let activeCall = activeCall else {
            assert(false, "This method should be called only if active call is non-nil")
            return
        }

        switch activeCall.call.status {
            case .Ringing:
                // no update for ringing status
                return
            case .Dialing:
                break
            case .Active:
                break
        }

        var activeController = activeCall.navigation.topViewController as? CallActiveController

        if (activeController == nil) {
            activeController = CallActiveController(theme: theme, callerName: activeCall.call.caller.nickname)
            activeController!.delegate = self

            activeCall.navigation.setViewControllers([activeController!], animated: false)
        }

        switch activeCall.call.status {
            case .Ringing:
                break
            case .Dialing:
                activeController!.state = .Reaching
            case .Active:
                activeController!.state = .Active(duration: activeCall.call.callDuration)
        }

        activeController!.outgoingVideo = activeCall.call.videoIsEnabled
    }
}
