//
//  CallActiveController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07.02.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

protocol CallActiveControllerDelegate: class {
    func callActiveController(controller: CallActiveController, mute: Bool)
    func callActiveController(controller: CallActiveController, speaker: Bool)
    func callActiveController(controller: CallActiveController, outgoingVideo: Bool)
    func callActiveControllerDecline(controller: CallActiveController)
}

private struct Constants {
    static let BigCenterContainerTopOffset = 50.0
    static let BigButtonOffset = 30.0

    static let SmallButtonOffset = 20.0
    static let SmallBottomOffset: CGFloat = -20.0

    static let VideoPreviewOffset = -20.0
    static let VideoPreviewSize = CGSize(width: 150.0, height: 110)

    static let ControlsAnimationDuration = 0.3
}

class CallActiveController: CallBaseController {
    enum State {
        case None
        case Reaching
        case Active(duration: NSTimeInterval)
    }

    weak var delegate: CallActiveControllerDelegate?

    var state: State = .None {
        didSet {
            // load view
            _ = view

            switch state {
                case .None:
                    infoLabel.text = nil
                case .Reaching:
                    infoLabel.text = String(localized: "call_reaching")
                case .Active(let duration):
                    infoLabel.text = String(timeInterval: duration)
            }
        }
    }

    var mute: Bool = false {
        didSet {
            bigMuteButton?.selected = mute
            smallMuteButton?.selected = mute
        }
    }

    var speaker: Bool = false {
        didSet {
            bigSpeakerButton?.selected = speaker
            smallSpeakerButton?.selected = speaker
        }
    }

    var outgoingVideo: Bool = false {
        didSet {
            bigVideoButton?.selected = outgoingVideo
            smallVideoButton?.selected = outgoingVideo
        }
    }

    var videoFeed: UIView? {
        didSet {
            if oldValue === videoFeed {
                return
            }

            if let old = oldValue {
                old.removeFromSuperview()
            }

            if let feed = videoFeed {
                view.insertSubview(feed, belowSubview: videoPreviewView)

                feed.bounds.size = view.bounds.size

                feed.snp_makeConstraints {
                    $0.edges.equalTo(view)
                }

                updateViewsWithTraitCollection(self.traitCollection)
            }
        }
    }

    var videoPreviewLayer: CALayer? {
        didSet {
            if oldValue === videoPreviewLayer {
                return
            }

            if let old = oldValue {
                old.removeFromSuperlayer()
                videoPreviewView.hidden = true
            }

            if let layer = videoPreviewLayer {
                videoPreviewView.layer.addSublayer(layer)
                videoPreviewView.hidden = false
                view.layoutIfNeeded()
            }

            updateViewsWithTraitCollection(self.traitCollection)
        }
    }

    private var showControls = true {
        didSet {
            let offset = showControls ? Constants.SmallBottomOffset : smallContainerView.frame.size.height
            smallContainerViewBottomConstraint.updateOffset(offset)

            toggleTopContainer(hidden: !showControls)

            UIView.animateWithDuration(Constants.ControlsAnimationDuration) { [unowned self] in
                self.view.layoutIfNeeded()
            }
        }
    }

    private var videoPreviewView: UIView!

    private var bigContainerView: UIView!
    private var bigCenterContainer: UIView!
    private var bigMuteButton: CallButton?
    private var bigSpeakerButton: CallButton?
    private var bigVideoButton: CallButton?
    private var bigDeclineButton: CallButton?

    private var smallContainerViewBottomConstraint: Constraint!

    private var smallContainerView: UIView!
    private var smallMuteButton: CallButton?
    private var smallSpeakerButton: CallButton?
    private var smallVideoButton: CallButton?
    private var smallDeclineButton: CallButton?

    override init(theme: Theme, callerName: String) {
        super.init(theme: theme, callerName: callerName)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        createGestureRecognizers()
        createVideoPreviewView()
        createBigViews()
        createSmallViews()
        installConstraints()

        setButtonsInitValues()

        updateViewsWithTraitCollection(self.traitCollection)
    }

    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        updateViewsWithTraitCollection(newCollection)
        showControls = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let layer = videoPreviewLayer {
            layer.frame.size = videoPreviewView.frame.size
        }
    }

    override func prepareForRemoval() {
        super.prepareForRemoval()

        bigMuteButton?.enabled = false
        bigSpeakerButton?.enabled = false
        bigVideoButton?.enabled = false
        bigDeclineButton?.enabled = false

        smallMuteButton?.enabled = false
        smallSpeakerButton?.enabled = false
        smallVideoButton?.enabled = false
        smallDeclineButton?.enabled = false
    }
}

// MARK: Actions
extension CallActiveController {
    func tapOnView() {
        guard !smallContainerView.hidden else {
            return
        }

        showControls = !showControls
    }

    func muteButtonPressed(button: CallButton) {
        mute = !button.selected
        delegate?.callActiveController(self, mute: mute)
    }

    func speakerButtonPressed(button: CallButton) {
        speaker = !button.selected
        delegate?.callActiveController(self, speaker: speaker)
    }

    func videoButtonPressed(button: CallButton) {
        outgoingVideo = !button.selected
        delegate?.callActiveController(self, outgoingVideo: outgoingVideo)
    }

    func declineButtonPressed() {
        delegate?.callActiveControllerDecline(self)
    }
}

private extension CallActiveController {
    func createGestureRecognizers() {
        let tapGR = UITapGestureRecognizer(target: self, action: "tapOnView")
        view.addGestureRecognizer(tapGR)
    }

    func createVideoPreviewView() {
        videoPreviewView = UIView()
        videoPreviewView.backgroundColor = theme.colorForType(.CallVideoPreviewBackground)
        view.addSubview(videoPreviewView)

        videoPreviewView.hidden = !outgoingVideo
    }

    func createBigViews() {
        bigContainerView = UIView()
        bigContainerView.backgroundColor = .clearColor()
        view.addSubview(bigContainerView)

        bigCenterContainer = UIView()
        bigCenterContainer.backgroundColor = .clearColor()
        bigContainerView.addSubview(bigCenterContainer)

        bigMuteButton = addButtonWithType(.Mute, buttonSize: .Big, action: "muteButtonPressed:", container: bigCenterContainer)
        bigSpeakerButton = addButtonWithType(.Speaker, buttonSize: .Big, action: "speakerButtonPressed:", container: bigCenterContainer)
        bigVideoButton = addButtonWithType(.Video, buttonSize: .Big, action: "videoButtonPressed:", container: bigCenterContainer)
        bigDeclineButton = addButtonWithType(.Decline, buttonSize: .Small, action: "declineButtonPressed", container: bigContainerView)
    }

    func createSmallViews() {
        smallContainerView = UIView()
        smallContainerView.backgroundColor = .clearColor()
        view.addSubview(smallContainerView)

        smallMuteButton = addButtonWithType(.Mute, buttonSize: .Small, action: "muteButtonPressed:", container: smallContainerView)
        smallSpeakerButton = addButtonWithType(.Speaker, buttonSize: .Small, action: "speakerButtonPressed:", container: smallContainerView)
        smallVideoButton = addButtonWithType(.Video, buttonSize: .Small, action: "videoButtonPressed:", container: smallContainerView)
        smallDeclineButton = addButtonWithType(.Decline, buttonSize: .Small, action: "declineButtonPressed", container: smallContainerView)
    }

    func addButtonWithType(type: CallButton.ButtonType, buttonSize: CallButton.ButtonSize, action: Selector, container: UIView) -> CallButton {
        let button = CallButton(theme: theme, type: type, buttonSize: buttonSize)
        button.addTarget(self, action: action, forControlEvents: .TouchUpInside)
        container.addSubview(button)

        return button
    }

    func installConstraints() {
        videoPreviewView.snp_makeConstraints {
            $0.right.equalTo(view).offset(Constants.VideoPreviewOffset)
            $0.bottom.equalTo(smallContainerView.snp_top).offset(Constants.VideoPreviewOffset)
            $0.width.equalTo(Constants.VideoPreviewSize.width)
            $0.height.equalTo(Constants.VideoPreviewSize.height)
        }

        bigContainerView.snp_makeConstraints {
            $0.top.equalTo(topContainer.snp_bottom)
            $0.left.right.bottom.equalTo(view)
        }

        bigCenterContainer.snp_makeConstraints {
            $0.centerX.equalTo(bigContainerView)
            $0.centerY.equalTo(view)
        }

        bigMuteButton!.snp_makeConstraints {
            $0.top.equalTo(bigCenterContainer)
            $0.left.equalTo(bigCenterContainer)
        }

        bigSpeakerButton!.snp_makeConstraints {
            $0.top.equalTo(bigCenterContainer)
            $0.right.equalTo(bigCenterContainer)
            $0.left.equalTo(bigMuteButton!.snp_right).offset(Constants.BigButtonOffset)
        }

        bigVideoButton!.snp_makeConstraints {
            $0.top.equalTo(bigMuteButton!.snp_bottom).offset(Constants.BigButtonOffset)
            $0.left.equalTo(bigCenterContainer)
            $0.bottom.equalTo(bigCenterContainer)
        }

        bigDeclineButton!.snp_makeConstraints {
            $0.centerX.equalTo(bigContainerView)
            $0.top.greaterThanOrEqualTo(bigCenterContainer).offset(Constants.BigButtonOffset)
            $0.bottom.equalTo(bigContainerView).offset(-Constants.BigButtonOffset)
        }

        smallContainerView.snp_makeConstraints {
            smallContainerViewBottomConstraint = $0.bottom.equalTo(view).offset(Constants.SmallBottomOffset).constraint
            $0.centerX.equalTo(view)
        }

        smallMuteButton!.snp_makeConstraints {
            $0.top.bottom.equalTo(smallContainerView)
            $0.left.equalTo(smallContainerView)
        }

        smallSpeakerButton!.snp_makeConstraints {
            $0.top.bottom.equalTo(smallContainerView)
            $0.left.equalTo(smallMuteButton!.snp_right).offset(Constants.SmallButtonOffset)
        }

        smallVideoButton!.snp_makeConstraints {
            $0.top.bottom.equalTo(smallContainerView)
            $0.left.equalTo(smallSpeakerButton!.snp_right).offset(Constants.SmallButtonOffset)
        }

        smallDeclineButton!.snp_makeConstraints {
            $0.top.bottom.equalTo(smallContainerView)
            $0.left.equalTo(smallVideoButton!.snp_right).offset(Constants.SmallButtonOffset)
            $0.right.equalTo(smallContainerView)
        }
    }

    func setButtonsInitValues() {
        bigMuteButton?.selected = mute
        smallMuteButton?.selected = mute

        bigSpeakerButton?.selected = speaker
        smallSpeakerButton?.selected = speaker

        bigVideoButton?.selected = outgoingVideo
        smallVideoButton?.selected = outgoingVideo
    }

    func updateViewsWithTraitCollection(traitCollection: UITraitCollection) {
        if videoFeed != nil || videoPreviewLayer != nil {
            bigContainerView.hidden = true
            smallContainerView.hidden = false
            return
        }

        switch traitCollection.verticalSizeClass {
            case .Regular:
                bigContainerView.hidden = false
                smallContainerView.hidden = true
            case .Unspecified:
                fallthrough
            case .Compact:
                bigContainerView.hidden = true
                smallContainerView.hidden = false
        }
    }
}
