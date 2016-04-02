//
//  CallIncomingController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 06.02.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let AvatarSize: CGFloat = 140.0

    static let ButtonContainerTopMinOffset = 10.0
    static let ButtonContainerBottomOffset = -50.0

    static let ButtonHorizontalOffset = 20.0
}

protocol CallIncomingControllerDelegate: class {
    func callIncomingControllerDecline(controller: CallIncomingController)
    func callIncomingControllerAnswerAudio(controller: CallIncomingController)
    func callIncomingControllerAnswerVideo(controller: CallIncomingController)
}

class CallIncomingController: CallBaseController {
    weak var delegate: CallIncomingControllerDelegate?

    private var avatarView: UIImageView!

    private var buttonContainer: UIView!
    private var declineButton: CallButton!
    private var audioButton: CallButton!
    private var videoButton: CallButton!

    override func loadView() {
        super.loadView()

        createViews()
        installConstraints()

        infoLabel.text = String(localized: "call_incoming")
    }

    override func prepareForRemoval() {
        super.prepareForRemoval()

        declineButton.enabled = false
        audioButton.enabled = false
        videoButton.enabled = false
    }
}

// MARK: Actions
extension CallIncomingController {
    func declineButtonPressed() {
        delegate?.callIncomingControllerDecline(self)
    }

    func audioButtonPressed() {
        delegate?.callIncomingControllerAnswerAudio(self)
    }

    func videoButtonPressed() {
        delegate?.callIncomingControllerAnswerVideo(self)
    }
}

private extension CallIncomingController {
    func createViews() {
        let avatarManager = AvatarManager(theme: theme)

        avatarView = UIImageView()
        avatarView.image = avatarManager.avatarFromString(callerName, diameter: Constants.AvatarSize, type: .Call)
        view.addSubview(avatarView)

        buttonContainer = UIView()
        buttonContainer.backgroundColor = .clearColor()
        view.addSubview(buttonContainer)

        declineButton = CallButton(theme: theme, type: .Decline, buttonSize: .Small)
        declineButton.addTarget(self, action: #selector(CallIncomingController.declineButtonPressed), forControlEvents: .TouchUpInside)
        buttonContainer.addSubview(declineButton)

        audioButton = CallButton(theme: theme, type: .AnswerAudio, buttonSize: .Small)
        audioButton.addTarget(self, action: #selector(CallIncomingController.audioButtonPressed), forControlEvents: .TouchUpInside)
        buttonContainer.addSubview(audioButton)

        videoButton = CallButton(theme: theme, type: .AnswerVideo, buttonSize: .Small)
        videoButton.addTarget(self, action: #selector(CallIncomingController.videoButtonPressed), forControlEvents: .TouchUpInside)
        buttonContainer.addSubview(videoButton)
    }

    func installConstraints() {
        avatarView.snp_makeConstraints {
            $0.center.equalTo(view)
        }

        buttonContainer.snp_makeConstraints {
            $0.centerX.equalTo(view)
            $0.top.greaterThanOrEqualTo(avatarView.snp_bottom).offset(Constants.ButtonContainerTopMinOffset)
            $0.bottom.equalTo(view).offset(Constants.ButtonContainerBottomOffset).priorityLow()
        }

        declineButton.snp_makeConstraints {
            $0.top.bottom.equalTo(buttonContainer)
            $0.left.equalTo(buttonContainer)
        }

        audioButton.snp_makeConstraints {
            $0.top.bottom.equalTo(buttonContainer)
            $0.left.equalTo(declineButton.snp_right).offset(Constants.ButtonHorizontalOffset)
        }

        videoButton.snp_makeConstraints {
            $0.top.bottom.equalTo(buttonContainer)
            $0.left.equalTo(audioButton.snp_right).offset(Constants.ButtonHorizontalOffset)
            $0.right.equalTo(buttonContainer)
        }
    }
}
