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
        nameLabel.font = UIFont.antidoteFontWithSize(16.0, weight: .Bold)
        addSubview(nameLabel)

        statusView = UserStatusView()
        statusView.showExternalCircle = false
        statusView.theme = theme
        addSubview(statusView)

        statusLabel = UILabel()
        statusLabel.textAlignment = .Center
        statusLabel.textColor = theme.colorForType(.NormalText)
        statusLabel.font = UIFont.antidoteFontWithSize(12.0, weight: .Light)
        addSubview(statusLabel)

        nameLabel.snp_makeConstraints {
            $0.top.equalTo(self)
            $0.leading.equalTo(self)
        }

        statusView.snp_makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.leading.equalTo(nameLabel.snp_trailing).offset(Constants.StatusViewLeftOffset)
            $0.trailing.equalTo(self)
            $0.size.equalTo(Constants.StatusViewSize)
        }

        statusLabel.snp_makeConstraints {
            $0.top.equalTo(nameLabel.snp_bottom)
            $0.leading.equalTo(nameLabel)
            $0.trailing.equalTo(nameLabel)
            $0.bottom.equalTo(self)
        }
    }

    func updateFrame() {
        nameLabel.sizeToFit()
        statusLabel.sizeToFit()

        frame.size.width = max(nameLabel.frame.size.width, statusLabel.frame.size.width) + Constants.StatusViewLeftOffset + Constants.StatusViewSize
        frame.size.height = nameLabel.frame.size.height + statusLabel.frame.size.height
    }
}
