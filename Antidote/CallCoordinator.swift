// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol CallCoordinatorDelegate: class {
    func callCoordinator(coordinator: CallCoordinator, notifyAboutBackgroundCallFrom caller: String, userInfo: String)
    func callCoordinatorDidStartCall(coordinator: CallCoordinator)
    func callCoordinatorDidFinishCall(coordinator: CallCoordinator)
}

private struct Constants {
    static let DeclineAfterInterval = 1.5
}

private class ActiveCall {
    var callToken: RLMNotificationToken?

    private let call: OCTCall
    private let navigation: UINavigationController

    private var usingFrontCamera: Bool = true

    init(call: OCTCall, navigation: UINavigationController) {
        self.call = call
        self.navigation = navigation
    }

    deinit {
        callToken?.stop()
    }
}

class CallCoordinator: NSObject {
    weak var delegate: CallCoordinatorDelegate?

    private let theme: Theme
    private weak var presentingController: UIViewController!
    private weak var submanagerCalls: OCTSubmanagerCalls!
    private weak var submanagerObjects: OCTSubmanagerObjects!

    private let audioPlayer = AudioPlayer()

    private var activeCall: ActiveCall? {
        didSet {
            switch (oldValue, activeCall) {
                case (.None, .Some):
                    delegate?.callCoordinatorDidStartCall(self)
                case (.Some, .None):
                    delegate?.callCoordinatorDidFinishCall(self)
                default:
                    break
            }
        }
    }

    init(theme: Theme, presentingController: UIViewController, submanagerCalls: OCTSubmanagerCalls, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme
        self.presentingController = presentingController
        self.submanagerCalls = submanagerCalls
        self.submanagerObjects = submanagerObjects

        super.init()

        submanagerCalls.delegate = self
    }

    func callToChat(chat: OCTChat, enableVideo: Bool) {
        do {
            let call = try submanagerCalls.callToChat(chat, enableAudio: true, enableVideo: enableVideo)
            let friend = chat.friends.lastObject() as! OCTFriend

            let controller = CallActiveController(theme: theme, callerName: friend.nickname)
            controller.delegate = self

            startActiveCallWithCall(call, controller: controller)
        }
        catch let error as NSError {
            handleErrorWithType(.CallToChat, error: error)
        }
    }

    func answerIncomingCallWithUserInfo(userInfo: String) {
        guard let activeCall = activeCall else { return }
        guard activeCall.call.uniqueIdentifier == userInfo else { return }
        guard activeCall.call.status == .Ringing else { return }

        answerCall(enableVideo: false)
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

        let nickname = call.caller?.nickname ?? ""

        if !UIApplication.isActive {
            delegate?.callCoordinator(self, notifyAboutBackgroundCallFrom: nickname, userInfo: call.uniqueIdentifier)
        }

        let controller = CallIncomingController(theme: theme, callerName: nickname)
        controller.delegate = self

        startActiveCallWithCall(call, controller: controller)
    }
}

extension CallCoordinator: CallIncomingControllerDelegate {
    func callIncomingControllerDecline(controller: CallIncomingController) {
        declineCall(callWasRemoved: false)
    }

    func callIncomingControllerAnswerAudio(controller: CallIncomingController) {
        answerCall(enableVideo: false)
    }

    func callIncomingControllerAnswerVideo(controller: CallIncomingController) {
        answerCall(enableVideo: true)
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

    func callActiveControllerSwitchCamera(controller: CallActiveController) {
        guard let activeCall = activeCall else {
            assert(false, "This method should be called only if active call is non-nil")
            return
        }

        do {
            let front = !activeCall.usingFrontCamera
            try submanagerCalls.switchToCameraFront(front)

            self.activeCall?.usingFrontCamera = front
        }
        catch {
            handleErrorWithType(.CallSwitchCamera)
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

        audioPlayer.stopAll()

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

        activeCall = ActiveCall(call: call, navigation: navigation)

        let predicate = NSPredicate(format: "uniqueIdentifier == %@", call.uniqueIdentifier)
        let results = submanagerObjects.calls(predicate: predicate)
        activeCall!.callToken = results.addNotificationBlock { [unowned self] change in
            switch change {
                case .Initial:
                    break
                case .Update(_, let deletions, _, let modifications):
                    if deletions.count > 0 {
                        self.declineCall(callWasRemoved: true)
                    }
                    else if modifications.count > 0 {
                        self.activeCallWasUpdated()
                    }
                case .Error(let error):
                    fatalError("\(error)")
            }
        }

        presentingController.presentViewController(navigation, animated: true, completion: nil)
        activeCallWasUpdated()
    }

    func answerCall(enableVideo enableVideo: Bool) {
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
                if !audioPlayer.isPlayingSound(.Ringtone) {
                    audioPlayer.playSound(.Ringtone, loop: true)
                }

                // no update for ringing status
                return
            case .Dialing:
                if !audioPlayer.isPlayingSound(.Calltone) {
                    audioPlayer.playSound(.Calltone, loop: true)
                }
            case .Active:
                if audioPlayer.isPlaying() {
                    audioPlayer.stopAll()
                }
        }

        var activeController = activeCall.navigation.topViewController as? CallActiveController

        if (activeController == nil) {
            let nickname = activeCall.call.caller?.nickname ?? ""
            activeController = CallActiveController(theme: theme, callerName: nickname)
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
        if activeCall.call.videoIsEnabled {
            if activeController!.videoPreviewLayer == nil {
                submanagerCalls.getVideoCallPreview { [weak activeController] layer in
                    activeController?.videoPreviewLayer = layer
                }
            }
        }
        else {
            if activeController!.videoPreviewLayer != nil {
                activeController!.videoPreviewLayer = nil
            }
        }

        if activeCall.call.friendSendingVideo {
            if activeController!.videoFeed == nil {
                activeController!.videoFeed = submanagerCalls.videoFeed()
            }
        }
        else {
            if activeController!.videoFeed != nil {
                activeController!.videoFeed = nil
            }
        }
    }
}
