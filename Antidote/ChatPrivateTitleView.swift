// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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

    fileprivate var nameLabel: UILabel!
    fileprivate var statusView: UserStatusView!
    fileprivate var statusLabel: UILabel!

    init(theme: Theme) {
        super.init(frame: CGRect.zero)

        backgroundColor = .clear

        createViews(theme)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ChatPrivateTitleView {
    func createViews(_ theme: Theme) {
        nameLabel = UILabel()
        nameLabel.textAlignment = .center
        nameLabel.textColor = theme.colorForType(.NormalText)
        nameLabel.font = UIFont.antidoteFontWithSize(16.0, weight: .bold)
        addSubview(nameLabel)

        statusView = UserStatusView()
        statusView.showExternalCircle = false
        statusView.theme = theme
        addSubview(statusView)

        statusLabel = UILabel()
        statusLabel.textAlignment = .center
        statusLabel.textColor = theme.colorForType(.NormalText)
        statusLabel.font = UIFont.antidoteFontWithSize(12.0, weight: .light)
        addSubview(statusLabel)

        nameLabel.snp.makeConstraints {
            $0.top.equalTo(self)
            $0.leading.equalTo(self)
        }

        statusView.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel)
            $0.leading.equalTo(nameLabel.snp.trailing).offset(Constants.StatusViewLeftOffset)
            $0.trailing.equalTo(self)
            $0.size.equalTo(Constants.StatusViewSize)
        }

        statusLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom)
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
