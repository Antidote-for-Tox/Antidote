// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

class ChatOutgoingTextCell: ChatBaseTextCell {
    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        bubbleNormalBackground = theme.colorForType(.ChatOutgoingBubble)
        bubbleView.textColor = theme.colorForType(.ConnectingText)
        bubbleView.backgroundColor = bubbleNormalBackground
        bubbleView.tintColor = theme.colorForType(.NormalText)
    }

    override func installConstraints() {
        super.installConstraints()

        bubbleView.snp_makeConstraints {
            $0.top.equalTo(movableContentView).offset(ChatBaseTextCell.Constants.BubbleVerticalOffset)
            $0.bottom.equalTo(movableContentView).offset(-ChatBaseTextCell.Constants.BubbleVerticalOffset)
            $0.trailing.equalTo(movableContentView).offset(-ChatBaseTextCell.Constants.BubbleHorizontalOffset)
        }
    }
}
