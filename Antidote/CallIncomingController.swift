// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

private struct Constants {
    static let AvatarSize: CGFloat = 140.0

    static let ButtonContainerTopMinOffset = 10.0
    static let ButtonContainerBottomOffset = -50.0

    static let ButtonHorizontalOffset = 20.0
}

protocol CallIncomingControllerDelegate: class {
    func callIncomingControllerDecline(_ controller: CallIncomingController)
    func callIncomingControllerAnswerAudio(_ controller: CallIncomingController)
    func callIncomingControllerAnswerVideo(_ controller: CallIncomingController)
}

class CallIncomingController: CallBaseController {
    weak var delegate: CallIncomingControllerDelegate?

    fileprivate var avatarView: UIImageView!

    fileprivate var buttonContainer: UIView!
    fileprivate var declineButton: CallButton!
    fileprivate var audioButton: CallButton!
    fileprivate var videoButton: CallButton!

    override func loadView() {
        super.loadView()

        createViews()
        installConstraints()

        infoLabel.text = String(localized: "call_incoming")
    }

    override func prepareForRemoval() {
        super.prepareForRemoval()

        declineButton.isEnabled = false
        audioButton.isEnabled = false
        videoButton.isEnabled = false
    }
}

// MARK: Actions
extension CallIncomingController {
    @objc func declineButtonPressed() {
        delegate?.callIncomingControllerDecline(self)
    }

    @objc func audioButtonPressed() {
        delegate?.callIncomingControllerAnswerAudio(self)
    }

    @objc func videoButtonPressed() {
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
        buttonContainer.backgroundColor = .clear
        view.addSubview(buttonContainer)

        declineButton = CallButton(theme: theme, type: .decline, buttonSize: .small)
        declineButton.addTarget(self, action: #selector(CallIncomingController.declineButtonPressed), for: .touchUpInside)
        buttonContainer.addSubview(declineButton)

        audioButton = CallButton(theme: theme, type: .answerAudio, buttonSize: .small)
        audioButton.addTarget(self, action: #selector(CallIncomingController.audioButtonPressed), for: .touchUpInside)
        buttonContainer.addSubview(audioButton)

        videoButton = CallButton(theme: theme, type: .answerVideo, buttonSize: .small)
        videoButton.addTarget(self, action: #selector(CallIncomingController.videoButtonPressed), for: .touchUpInside)
        buttonContainer.addSubview(videoButton)
    }

    func installConstraints() {
        avatarView.snp.makeConstraints {
            $0.center.equalTo(view)
        }

        buttonContainer.snp.makeConstraints {
            $0.centerX.equalTo(view)
            $0.top.greaterThanOrEqualTo(avatarView.snp.bottom).offset(Constants.ButtonContainerTopMinOffset)
            $0.bottom.equalTo(view).offset(Constants.ButtonContainerBottomOffset).priority(250)
        }

        declineButton.snp.makeConstraints {
            $0.top.bottom.equalTo(buttonContainer)
            $0.leading.equalTo(buttonContainer)
        }

        audioButton.snp.makeConstraints {
            $0.top.bottom.equalTo(buttonContainer)
            $0.leading.equalTo(declineButton.snp.trailing).offset(Constants.ButtonHorizontalOffset)
        }

        videoButton.snp.makeConstraints {
            $0.top.bottom.equalTo(buttonContainer)
            $0.leading.equalTo(audioButton.snp.trailing).offset(Constants.ButtonHorizontalOffset)
            $0.trailing.equalTo(buttonContainer)
        }
    }
}
