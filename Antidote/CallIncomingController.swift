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

    static let ButtonSize: CGFloat = 60.0
    static let ButtonImageSize: CGFloat = 30.0
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
    private var declineButton: UIButton!
    private var audioButton: UIButton!
    private var videoButton: UIButton!

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

        let declineColor = theme.colorForType(.CallDeclineButtonBackground)
        let answerColor = theme.colorForType(.CallAnswerButtonBackground)

        declineButton = addButtonWithImageName("end-call", backgroundColor: declineColor, action: "declineButtonPressed")
        audioButton = addButtonWithImageName("start-call", backgroundColor: answerColor, action: "audioButtonPressed")
        videoButton = addButtonWithImageName("video-call", backgroundColor: answerColor, action: "videoButtonPressed")
    }

    func addButtonWithImageName(imageName: String, backgroundColor: UIColor, action: Selector) -> UIButton {
        let button = UIButton()
        button.tintColor = theme.colorForType(.CallButtonIconColor)
        button.layer.cornerRadius = Constants.ButtonSize / 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: action, forControlEvents: .TouchUpInside)

        let imageSize = CGSize(width: Constants.ButtonImageSize, height: Constants.ButtonImageSize)
        let image = UIImage(named: imageName)!.scaleToSize(imageSize).imageWithRenderingMode(.AlwaysTemplate)
        button.setImage(image, forState: .Normal)

        let bgImage = UIImage.imageWithColor(backgroundColor, size: CGSize(width: 1.0, height: 1.0))
        button.setBackgroundImage(bgImage, forState:UIControlState.Normal)

        buttonContainer.addSubview(button)

        return button
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
            $0.size.equalTo(Constants.ButtonSize)
        }

        audioButton.snp_makeConstraints {
            $0.top.bottom.equalTo(buttonContainer)
            $0.left.equalTo(declineButton.snp_right).offset(Constants.ButtonHorizontalOffset)
            $0.size.equalTo(Constants.ButtonSize)
        }

        videoButton.snp_makeConstraints {
            $0.top.bottom.equalTo(buttonContainer)
            $0.left.equalTo(audioButton.snp_right).offset(Constants.ButtonHorizontalOffset)
            $0.right.equalTo(buttonContainer)
            $0.size.equalTo(Constants.ButtonSize)
        }
    }
}
