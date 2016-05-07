//
//  ChatIncomingTextCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 16.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

class ChatIncomingTextCell: ChatBaseTextCell {
    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        bubbleNormalBackground = theme.colorForType(.ChatIncomingBubble)
        bubbleView.backgroundColor = bubbleNormalBackground
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
