//
//  ChatPrivateTitleView.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 16.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let StatusViewLeftOffset: CGFloat = 5.0
    static let StatusViewSize: CGFloat = 10.0
}

class ChatPrivateTitleView: UIView {
    var name: String {
        get {
            return nameLabel.text ?? ""
        }
        set {
            nameLabel.text = newValue

            updateFrame()
        }
    }

    var userStatus: UserStatus {
        get {
            return statusView.userStatus
        }
        set {
            statusView.userStatus = newValue
            statusLabel.text = newValue.toString()

            updateFrame()
        }
    }

    private var nameLabel: UILabel!
    private var statusView: UserStatusView!
    private var statusLabel: UILabel!

    init(theme: Theme) {
        super.init(frame: CGRectZero)

        backgroundColor = .clearColor()

        createViews(theme)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ChatPrivateTitleView {
    func createViews(theme: Theme) {
        nameLabel = UILabel()
        nameLabel.textAlignment = .Center
        nameLabel.textColor = theme.colorForType(.NormalText)
        nameLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightBold)
        addSubview(nameLabel)

        statusView = UserStatusView()
        statusView.showExternalCircle = false
        statusView.theme = theme
        addSubview(statusView)

        statusLabel = UILabel()
        statusLabel.textAlignment = .Center
        statusLabel.textColor = theme.colorForType(.NormalText)
        statusLabel.font = UIFont.systemFontOfSize(12.0, weight: UIFontWeightLight)
        addSubview(statusLabel)
    }

    func updateFrame() {
        nameLabel.sizeToFit()
        statusLabel.sizeToFit()

        // Yeah, manual stuff.. suffer!

        frame.size.width = max(
                nameLabel.frame.size.width + Constants.StatusViewLeftOffset + Constants.StatusViewSize,
                statusLabel.frame.size.width)
        frame.size.height = nameLabel.frame.size.height + statusLabel.frame.size.height

        nameLabel.frame.origin.x = (frame.size.width - nameLabel.frame.size.width) / 2

        statusView.frame.size.width = Constants.StatusViewSize
        statusView.frame.size.height = Constants.StatusViewSize
        statusView.frame.origin.x = Constants.StatusViewLeftOffset + CGRectGetMaxX(nameLabel.frame)
        statusView.frame.origin.y = (nameLabel.frame.size.height - statusView.frame.size.height) / 2

        statusLabel.frame.origin.x = (frame.size.width - statusLabel.frame.size.width) / 2
        statusLabel.frame.origin.y = CGRectGetMaxY(nameLabel.frame)
    }
}
