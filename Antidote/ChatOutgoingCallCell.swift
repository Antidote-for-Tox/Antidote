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
    static let ImageViewSize = 15.0

    static let RightOffset = -20.0
    static let ImageViewToLabelOffset = -5.0
    static let ImageViewYOffset = -1.0
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
            label.text = String(localized: "chat_missed_call_message")
        }
    }

    override func createViews() {
        super.createViews()

        var image = UIImage(named: "start-call")!
        image = image.scaleToSize(CGSize(width: Constants.ImageViewSize, height: Constants.ImageViewSize))
        image = image.imageWithRenderingMode(.AlwaysTemplate)

        callImageView = UIImageView(image: image)
        movableContentView.addSubview(callImageView)

        label = UILabel()
        label.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightLight)
        movableContentView.addSubview(label)
    }

    override func installConstraints() {
        super.installConstraints()

        callImageView.snp_makeConstraints {
            $0.centerY.equalTo(label).offset(Constants.ImageViewYOffset)
            $0.right.equalTo(label.snp_left).offset(Constants.ImageViewToLabelOffset)
        }

        label.snp_makeConstraints {
            $0.centerY.equalTo(movableContentView)
            $0.right.equalTo(movableContentView).offset(Constants.RightOffset)
        }
    }
}
