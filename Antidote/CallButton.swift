//
//  CallButton.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07.02.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit

private struct Constants {
    static let SmallSize: CGFloat = 60.0
    static let BigSize: CGFloat = 80.0
    static let ImageSize: CGFloat = 30.0
}

class CallButton: UIButton {
    enum ButtonSize {
        case Small
        case Big
    }

    enum ButtonType {
        case Decline
        case AnswerAudio
        case AnswerVideo
        case Mute
        case Speaker
        case Video
    }

    override var selected: Bool {
        didSet {
            if let selectedTintColor = selectedTintColor {
                tintColor = selected ? selectedTintColor : normalTintColor
            }
        }
    }

    override var highlighted: Bool {
        didSet {
            if highlighted {
                tintColor = normalTintColor
            }
            else {
                if let selectedTintColor = selectedTintColor {
                    tintColor = selected ? selectedTintColor : normalTintColor
                }
            }
        }
    }

    private let buttonSize: ButtonSize
    private let normalTintColor: UIColor
    private var selectedTintColor: UIColor?

    init(theme: Theme, type: ButtonType, buttonSize: ButtonSize) {
        self.buttonSize = buttonSize
        self.normalTintColor = theme.colorForType(.CallButtonIconColor)

        super.init(frame: CGRectZero)

        switch buttonSize {
            case .Small:
                layer.cornerRadius = Constants.SmallSize / 2
            case .Big:
                layer.cornerRadius = Constants.BigSize / 2
        }
        layer.masksToBounds = true

        let imageName: String
        let backgroundColor: UIColor
        var selectedBackgroundColor: UIColor? = nil

        switch type {
            case .Decline:
                imageName = "end-call"
                backgroundColor = theme.colorForType(.CallDeclineButtonBackground)
            case .AnswerAudio:
                imageName = "start-call"
                backgroundColor = theme.colorForType(.CallAnswerButtonBackground)
            case .AnswerVideo:
                imageName = "video-call"
                backgroundColor = theme.colorForType(.CallAnswerButtonBackground)
            case .Mute:
                imageName = "mute"
                backgroundColor = theme.colorForType(.CallControlBackground)
                selectedTintColor = theme.colorForType(.CallButtonSelectedIconColor)
                selectedBackgroundColor = theme.colorForType(.CallControlSelectedBackground)
            case .Speaker:
                imageName = "speaker"
                backgroundColor = theme.colorForType(.CallControlBackground)
                selectedTintColor = theme.colorForType(.CallButtonSelectedIconColor)
                selectedBackgroundColor = theme.colorForType(.CallControlSelectedBackground)
            case .Video:
                imageName = "video-call"
                backgroundColor = theme.colorForType(.CallControlBackground)
                selectedTintColor = theme.colorForType(.CallButtonSelectedIconColor)
                selectedBackgroundColor = theme.colorForType(.CallControlSelectedBackground)
        }

        tintColor = normalTintColor

        let imageSize = CGSize(width: Constants.ImageSize, height: Constants.ImageSize)
        let image = UIImage.templateNamed(imageName).scaleToSize(imageSize)
        setImage(image, forState: .Normal)

        let backgroundImage = UIImage.imageWithColor(backgroundColor, size: CGSize(width: 1.0, height: 1.0))
        setBackgroundImage(backgroundImage, forState:UIControlState.Normal)

        if let selected = selectedBackgroundColor {
            let backgroundImage = UIImage.imageWithColor(selected, size: CGSize(width: 1.0, height: 1.0))
            setBackgroundImage(backgroundImage, forState:UIControlState.Selected)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func intrinsicContentSize() -> CGSize {
        switch buttonSize {
            case .Small:
                return CGSize(width: Constants.SmallSize, height: Constants.SmallSize)
            case .Big:
                return CGSize(width: Constants.BigSize, height: Constants.BigSize)
        }
    }
}
