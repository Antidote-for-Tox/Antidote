//
//  NotificationView.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 20.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit

class NotificationView: UIView {
    struct Constants {
        static let Offset = 10.0
        static let LabelsOffset = -5.0

        static let ImageSize: CGFloat = 34.0
        static let CloseButtonWidth = 34.0
    }

    private let tapHandler: Void -> Void
    private let closeHandler: Void -> Void

    private var imageView: UIImageView!
    private var topLabel: UILabel!
    private var bottomLabel: UILabel!

    private var fullSizeButton: UIButton!
    private var closeButton: UIButton!

    init(theme: Theme, image: UIImage, topText: String, bottomText: String, tapHandler: Void -> Void, closeHandler: Void -> Void) {
        self.tapHandler = tapHandler
        self.closeHandler = closeHandler

        super.init(frame: CGRectZero)

        backgroundColor = theme.colorForType(.NotificationBackground)

        createViews(theme: theme)
        installConstraints()

        imageView.image = image
        topLabel.text = topText
        bottomLabel.text = bottomText
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NotificationView {
    func fullSizeButtonPressed() {
        tapHandler()
    }

    func closeButtonPressed() {
        closeHandler()
    }
}

private extension NotificationView {
    func createViews(theme theme: Theme) {
        imageView = UIImageView()
        imageView.backgroundColor = .clearColor()
        imageView.layer.cornerRadius = Constants.ImageSize / 2
        imageView.layer.masksToBounds = true
        addSubview(imageView)

        topLabel = UILabel()
        topLabel.textColor = theme.colorForType(.NotificationText)
        topLabel.backgroundColor = .clearColor()
        topLabel.font = UIFont.systemFontOfSize(16.0)
        addSubview(topLabel)

        bottomLabel = UILabel()
        bottomLabel.textColor = theme.colorForType(.NotificationText)
        bottomLabel.backgroundColor = .clearColor()
        bottomLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightLight)
        addSubview(bottomLabel)

        fullSizeButton = UIButton()
        fullSizeButton.addTarget(self, action: "fullSizeButtonPressed", forControlEvents: .TouchUpInside)
        addSubview(fullSizeButton)

        let image = UIImage.templateNamed("notification-close")

        closeButton = UIButton()
        closeButton.setImage(image, forState: .Normal)
        closeButton.tintColor = theme.colorForType(.NotificationText)
        closeButton.addTarget(self, action: "closeButtonPressed", forControlEvents: .TouchUpInside)
        addSubview(closeButton)
    }

    func installConstraints() {
        imageView.snp_makeConstraints {
            $0.left.equalTo(self).offset(Constants.Offset)
            $0.centerY.equalTo(self)
            $0.size.equalTo(Constants.ImageSize)
        }

        topLabel.snp_makeConstraints {
            $0.top.equalTo(self)
            $0.left.equalTo(imageView.snp_right).offset(Constants.Offset)
        }

        bottomLabel.snp_makeConstraints {
            $0.top.equalTo(topLabel.snp_bottom).offset(Constants.LabelsOffset)
            $0.left.equalTo(topLabel)
            $0.right.equalTo(topLabel)
            $0.bottom.equalTo(self)
        }

        fullSizeButton.snp_makeConstraints {
            $0.edges.equalTo(self)
        }

        closeButton.snp_makeConstraints {
            $0.left.equalTo(topLabel.snp_right)
            $0.right.equalTo(self)
            $0.top.bottom.equalTo(self)
            $0.width.equalTo(Constants.CloseButtonWidth)
        }
    }
}
