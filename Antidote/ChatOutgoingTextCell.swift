//
//  ChatOutgoingTextCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 16.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

class ChatOutgoingTextCell: ChatBaseTextCell {
    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        bubbleNormalBackground = theme.colorForType(.ChatOutgoingBubble)
        bubbleView.backgroundColor = bubbleNormalBackground
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
