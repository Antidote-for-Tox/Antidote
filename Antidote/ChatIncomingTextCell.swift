// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

class ChatIncomingTextCell: ChatBaseTextCell {
    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        bubbleNormalBackground = theme.colorForType(.ChatIncomingBubble)
        bubbleView.backgroundColor = bubbleNormalBackground
        bubbleView.tintColor = theme.colorForType(.LinkText)
    }

    override func installConstraints() {
        super.installConstraints()

        bubbleView.snp_makeConstraints {
            $0.top.equalTo(contentView).offset(ChatBaseTextCell.Constants.BubbleVerticalOffset)
            $0.bottom.equalTo(contentView).offset(-ChatBaseTextCell.Constants.BubbleVerticalOffset)
            $0.leading.equalTo(contentView).offset(ChatBaseTextCell.Constants.BubbleHorizontalOffset)
        }
    }
}

// Accessibility
extension ChatIncomingTextCell {
    override var accessibilityLabel: String? {
        get {
            return String(localized: "accessibility_incoming_message_label")
        }
        set {}
    }
}
