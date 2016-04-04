//
//  ChatIncomingTextCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 16.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let BubbleVerticalOffset = 7.0
    static let BubbleLeftOffset = 20.0

}

class ChatIncomingTextCell: ChatMovableDateCell {
    private var bubbleView: BubbleView!

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let incomingModel = model as? ChatIncomingTextCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        bubbleView.text = incomingModel.message
        bubbleView.textColor = theme.colorForType(.NormalText)
        bubbleView.tintColor = theme.colorForType(.LinkText)
        bubbleView.backgroundColor = theme.colorForType(.ChatIncomingBubble)
    }

    override func createViews() {
        super.createViews()

        bubbleView = BubbleView()
        contentView.addSubview(bubbleView)
    }

    override func installConstraints() {
        super.installConstraints()

        bubbleView.snp_makeConstraints {
            $0.top.equalTo(contentView).offset(Constants.BubbleVerticalOffset)
            $0.bottom.equalTo(contentView).offset(-Constants.BubbleVerticalOffset)
            $0.left.equalTo(contentView).offset(Constants.BubbleLeftOffset)
        }
    }
}
