//
//  StaticTableInfoCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 22.02.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

class StaticTableInfoCell: StaticTableBaseCell {
    private var valueChangedHandler: (Bool -> Void)?

    private var titleLabel: UILabel!
    private var valueLabel: UILabel!

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let infoModel = model as? StaticTableInfoCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        selectionStyle = .None

        titleLabel.textColor = theme.colorForType(.NormalText)
        titleLabel.text = infoModel.title

        valueLabel.textColor = theme.colorForType(.LinkText)
        valueLabel.text = infoModel.value
    }

    override func createViews() {
        super.createViews()

        titleLabel = UILabel()
        titleLabel.backgroundColor = UIColor.clearColor()
        customContentView.addSubview(titleLabel)

        valueLabel = UILabel()
        valueLabel.backgroundColor = UIColor.clearColor()
        customContentView.addSubview(valueLabel)
    }

    override func installConstraints() {
        super.installConstraints()

        titleLabel.snp_makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.left.equalTo(customContentView)
        }

        valueLabel.snp_makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.left.greaterThanOrEqualTo(titleLabel.snp_right)
            $0.right.equalTo(customContentView)
        }
    }
}
