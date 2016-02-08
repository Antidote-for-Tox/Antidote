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
    private var call: OCTCall
    private let navigation: UINavigationController
}

class CallCoordinator: NSObject {
    private let theme: Theme
    private weak var presentingController: UIViewController!
    private weak var submanagerCalls: OCTSubmanagerCalls!

    private var activeCall: ActiveCall?

    init(theme: Theme, presentingController: UIViewController, submanagerCalls: OCTSubmanagerCalls, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme
        self.presentingController = presentingController
        self.submanagerCalls = submanagerCalls

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
        declineCall()
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

    }

    func callActiveController(controller: CallActiveController, speaker: Bool) {

    }

    func callActiveController(controller: CallActiveController, outgoingVideo: Bool) {

    }

    func callActiveControllerDecline(controller: CallActiveController) {
        declineCall()
    }
}

private extension CallCoordinator {
    func declineCall() {
        guard let activeCall = activeCall else {
            assert(false, "This method should be called only if active call is non-nil")
            return
        }

        _ = try? submanagerCalls.sendCallControl(.Cancel, toCall: activeCall.call)

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

        presentingController.presentViewController(navigation, animated: true, completion: nil)

        activeCall = ActiveCall(call: call, navigation: navigation)
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

            let activeController = CallActiveController(theme: theme, callerName: controller.callerName)
            activeController.delegate = self
            activeController.outgoingVideo = enableVideo

            activeCall.navigation.setViewControllers([activeController], animated: false)
        }
        catch let error as NSError {
            handleErrorWithType(.AnswerCall, error: error)

            declineCall()
        }
    }
}
