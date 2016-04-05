//
//  ChatMovableDateCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 16.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

class ChatMovableDateCell: BaseCell {
    /**
        Superview for content that should move while panning table to the left.
     */
    var movableContentView: UIView!

    var movableOffset: CGFloat = 0 {
        didSet {
            if movableOffset > 0.0 {
                movableOffset = 0.0
            }

            let minOffset = -dateLabel.frame.size.width - 5.0

            if movableOffset < minOffset {
                movableOffset = minOffset
            }

            movableContentViewLeftConstraint.updateOffset(movableOffset)
            layoutIfNeeded()
        }
    }

    private var movableContentViewLeftConstraint: Constraint!
    private var dateLabel: UILabel!

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let movableModel = model as? ChatMovableDateCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        dateLabel.text = movableModel.dateString
        dateLabel.textColor = theme.colorForType(.ChatListCellMessage)
    }

    override func createViews() {
        super.createViews()

        movableContentView = UIView()
        movableContentView.backgroundColor = .clearColor()
        contentView.addSubview(movableContentView)

        dateLabel = UILabel()
        dateLabel.font = UIFont.antidoteFontWithSize(12.0, weight: .Light)
        movableContentView.addSubview(dateLabel)
    }

    override func installConstraints() {
        super.installConstraints()

        movableContentView.snp_makeConstraints {
            $0.top.equalTo(contentView)
            movableContentViewLeftConstraint = $0.leading.equalTo(contentView).constraint
            $0.size.equalTo(contentView)
        }

        dateLabel.snp_makeConstraints {
            $0.centerY.equalTo(movableContentView)
            $0.leading.equalTo(movableContentView.snp_trailing)
        }
    }
}
