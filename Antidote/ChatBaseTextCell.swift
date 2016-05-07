//
//  ChatBaseTextCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 19/07/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit

class ChatBaseTextCell: ChatMovableDateCell {
    struct Constants {
        static let BubbleVerticalOffset = 7.0
        static let BubbleHorizontalOffset = 20.0
    }

    var bubbleNormalBackground: UIColor?
    var bubbleView: BubbleView!
    
    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let textModel = model as? ChatBaseTextCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        canBeCopied = true
        bubbleView.text = textModel.message
        bubbleView.textColor = theme.colorForType(.NormalText)
        bubbleView.tintColor = theme.colorForType(.LinkText)
    }

    override func createViews() {
        super.createViews()

        bubbleView = BubbleView()
        contentView.addSubview(bubbleView)
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        bubbleView.userInteractionEnabled = !editing
    }

    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        bubbleView.backgroundColor = bubbleNormalBackground
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if editing {
            bubbleView.backgroundColor = bubbleNormalBackground
            return
        }

        if selected {
            bubbleView.backgroundColor = bubbleNormalBackground?.darkerColor()
        }
        else {
            bubbleView.backgroundColor = bubbleNormalBackground
        }
    }
}

// ChatEditable
extension ChatBaseTextCell {
    override func shouldShowMenu() -> Bool {
        return true
    }

    override func menuTargetRect() -> CGRect {
        return bubbleView.frame
    }

    override func willShowMenu() {
        super.willShowMenu()

        bubbleView.selectable = false
    }

    override func willHideMenu() {
        super.willHideMenu()

        bubbleView.selectable = true
    }
}
