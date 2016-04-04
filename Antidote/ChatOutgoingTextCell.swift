//
//  ChatOutgoingTextCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 16.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let BubbleVerticalOffset = 7.0
    static let BubbleRightOffset = -20.0
}

class ChatOutgoingTextCell: ChatMovableDateCell {
    private var bubbleView: BubbleView!

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let outgoingModel = model as? ChatOutgoingTextCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        bubbleView.text = outgoingModel.message
        bubbleView.textColor = theme.colorForType(.NormalText)
        bubbleView.tintColor = theme.colorForType(.LinkText)
        bubbleView.backgroundColor = theme.colorForType(.ChatOutgoingBubble)
    }

    override func createViews() {
        super.createViews()

        bubbleView = BubbleView()
        movableContentView.addSubview(bubbleView)
    }

    override func installConstraints() {
        super.installConstraints()

        bubbleView.snp_makeConstraints {
            $0.top.equalTo(movableContentView).offset(Constants.BubbleVerticalOffset)
            $0.bottom.equalTo(movableContentView).offset(-Constants.BubbleVerticalOffset)
            $0.right.equalTo(movableContentView).offset(Constants.BubbleRightOffset)
        }
    }
}
