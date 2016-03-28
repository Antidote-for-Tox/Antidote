//
//  ChatIncomingCallCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 12.02.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let LeftOffset = 20.0
    static let ImageViewToLabelOffset = 5.0
    static let ImageViewYOffset = -1.0
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

        var image = UIImage.templateNamed("start-call-small")

        callImageView = UIImageView(image: image)
        contentView.addSubview(callImageView)

        label = UILabel()
        label.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightLight)
        contentView.addSubview(label)
    }

    override func installConstraints() {
        super.installConstraints()

        callImageView.snp_makeConstraints {
            $0.centerY.equalTo(label).offset(Constants.ImageViewYOffset)
            $0.left.equalTo(contentView).offset(Constants.LeftOffset)
        }

        label.snp_makeConstraints {
            $0.centerY.equalTo(contentView)
            $0.left.equalTo(callImageView.snp_right).offset(Constants.ImageViewToLabelOffset)
        }
    }
}
