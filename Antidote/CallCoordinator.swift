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

        let navigation = UINavigationController(rootViewController: controller)
        navigation.modalPresentationStyle = .OverCurrentContext
        navigation.navigationBarHidden = true
        navigation.modalTransitionStyle = .CrossDissolve

        presentingController.presentViewController(navigation, animated: true, completion: nil)

        activeCall = ActiveCall(call: call, navigation: navigation)
    }
}

extension CallCoordinator: CallIncomingControllerDelegate {
    func callIncomingControllerDecline(controller: CallIncomingController) {
        declineCall()
    }

    func callIncomingControllerAnswerAudio(controller: CallIncomingController) {
        // TODO
    }

    func callIncomingControllerAnswerVideo(controller: CallIncomingController) {
        // TODO
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
}
