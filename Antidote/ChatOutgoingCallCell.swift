//
//  ChatOutgoingCallCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 13.02.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let RightOffset = -20.0
    static let ImageViewToLabelOffset = -5.0
    static let ImageViewYOffset = -1.0
    static let VerticalOffset = 8.0
}

class ChatOutgoingCallCell: ChatMovableDateCell {
    private var callImageView: UIImageView!
    private var label: UILabel!

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let outgoingModel = model as? ChatOutgoingCallCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        label.textColor = theme.colorForType(.ChatListCellMessage)
        callImageView.tintColor = theme.colorForType(.LinkText)

        if outgoingModel.answered {
            label.text = String(localized: "chat_call_message") + String(timeInterval: outgoingModel.callDuration)
        }
        else {
            label.text = String(localized: "chat_unanwered_call")
        }
    }

    override func createViews() {
        super.createViews()

        let image = UIImage.templateNamed("start-call-small")

        callImageView = UIImageView(image: image)
        movableContentView.addSubview(callImageView)

        label = UILabel()
        label.font = UIFont.antidoteFontWithSize(16.0, weight: .Light)
        movableContentView.addSubview(label)
    }

    override func installConstraints() {
        super.installConstraints()

        callImageView.snp_makeConstraints {
            $0.centerY.equalTo(label).offset(Constants.ImageViewYOffset)
            $0.trailing.equalTo(label.snp_leading).offset(Constants.ImageViewToLabelOffset)
        }

        label.snp_makeConstraints {
            $0.top.equalTo(contentView).offset(Constants.VerticalOffset)
            $0.bottom.equalTo(contentView).offset(-Constants.VerticalOffset)
            $0.trailing.equalTo(movableContentView).offset(Constants.RightOffset)
        }
    }
}

// ChatEditable
extension ChatOutgoingCallCell {
    override func shouldShowMenu() -> Bool {
        return true
    }

    override func menuTargetRect() -> CGRect {
        return label.frame
    }
}
