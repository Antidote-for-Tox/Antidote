// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

private struct Constants {
    static let LeftOffset = 20.0
    static let ImageViewToLabelOffset = 5.0
    static let ImageViewYOffset = -1.0
    static let VerticalOffset = 8.0
}

class ChatIncomingCallCell: ChatMovableDateCell {
    private var callImageView: UIImageView!
    private var label: UILabel!

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let incomingModel = model as? ChatIncomingCallCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        label.textColor = theme.colorForType(.ChatListCellMessage)
        callImageView.tintColor = theme.colorForType(.LinkText)

        if incomingModel.answered {
            label.text = String(localized: "chat_call_message") + String(timeInterval: incomingModel.callDuration)
        }
        else {
            label.text = String(localized: "chat_missed_call_message")
        }
    }

    override func createViews() {
        super.createViews()

        let image = UIImage.templateNamed("start-call-small")

        callImageView = UIImageView(image: image)
        contentView.addSubview(callImageView)

        label = UILabel()
        label.font = UIFont.antidoteFontWithSize(16.0, weight: .Light)
        contentView.addSubview(label)
    }

    override func installConstraints() {
        super.installConstraints()

        callImageView.snp_makeConstraints {
            $0.centerY.equalTo(label).offset(Constants.ImageViewYOffset)
            $0.leading.equalTo(contentView).offset(Constants.LeftOffset)
        }

        label.snp_makeConstraints {
            $0.top.equalTo(contentView).offset(Constants.VerticalOffset)
            $0.bottom.equalTo(contentView).offset(-Constants.VerticalOffset)
            $0.leading.equalTo(callImageView.snp_trailing).offset(Constants.ImageViewToLabelOffset)
        }
    }
}

// Accessibility
extension ChatIncomingCallCell {
    override var accessibilityLabel: String? {
        get {
            return label.text
        }
        set {}
    }
}

// ChatEditable
extension ChatIncomingCallCell {
    override func shouldShowMenu() -> Bool {
        return true
    }

    override func menuTargetRect() -> CGRect {
        return label.frame
    }
}
