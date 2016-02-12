//
//  StaticTableSwitchCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 22.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

class StaticTableSwitchCell: StaticTableBaseCell {
    private var valueChangedHandler: (Bool -> Void)?

    private var titleLabel: UILabel!
    private var switchView: UISwitch!

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let switchModel = model as? StaticTableSwitchCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        selectionStyle = .None

        titleLabel.textColor = theme.colorForType(.NormalText)
        titleLabel.text = switchModel.title

        switchView.tintColor = theme.colorForType(.LinkText)
        switchView.on = switchModel.on

        valueChangedHandler = switchModel.valueChangedHandler
    }

    override func createViews() {
        super.createViews()

        titleLabel = UILabel()
        titleLabel.backgroundColor = UIColor.clearColor()
        customContentView.addSubview(titleLabel)

        switchView = UISwitch()
        switchView.addTarget(self, action: "switchValueChanged", forControlEvents: .ValueChanged)
        customContentView.addSubview(switchView)
    }

    override func installConstraints() {
        super.installConstraints()

        titleLabel.snp_makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.left.equalTo(customContentView)
        }

        switchView.snp_makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.left.greaterThanOrEqualTo(titleLabel.snp_right)
            $0.right.equalTo(customContentView)
        }
    }
}

extension StaticTableSwitchCell {
    func switchValueChanged() {
        valueChangedHandler?(switchView.on)
    }
}
