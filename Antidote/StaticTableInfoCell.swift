//
//  StaticTableInfoCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 22.02.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let ValueToArrowOffset = 6.0
}

class StaticTableInfoCell: StaticTableBaseCell {
    private var valueChangedHandler: (Bool -> Void)?

    private var titleLabel: UILabel!
    private var valueLabel: UILabel!
    private var arrowImageView: UIImageView!

    private var valueLabelToContentRightConstraint: Constraint!
    private var valueLabelToArrowConstraint: Constraint!

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let infoModel = model as? StaticTableInfoCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        titleLabel.textColor = theme.colorForType(.NormalText)
        titleLabel.text = infoModel.title

        valueLabel.textColor = theme.colorForType(.LinkText)
        valueLabel.text = infoModel.value


        if infoModel.showArrow {
            arrowImageView.hidden = false
            valueLabelToContentRightConstraint.deactivate()
            valueLabelToArrowConstraint.activate()
            selectionStyle = .Default
        }
        else {
            arrowImageView.hidden = true
            valueLabelToArrowConstraint.deactivate()
            valueLabelToContentRightConstraint.activate()
            selectionStyle = .None
        }
    }

    override func createViews() {
        super.createViews()

        titleLabel = UILabel()
        titleLabel.backgroundColor = UIColor.clearColor()
        customContentView.addSubview(titleLabel)

        valueLabel = UILabel()
        valueLabel.backgroundColor = UIColor.clearColor()
        customContentView.addSubview(valueLabel)

        arrowImageView = UIImageView()
        arrowImageView.image = UIImage(named: "right-arrow")!.flippedToCorrectLayout()
        customContentView.addSubview(arrowImageView)
    }

    override func installConstraints() {
        super.installConstraints()

        titleLabel.snp_makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.leading.equalTo(customContentView)
        }

        valueLabel.snp_makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.leading.greaterThanOrEqualTo(titleLabel.snp_trailing)
            valueLabelToContentRightConstraint = $0.trailing.equalTo(customContentView).constraint
        }

        valueLabelToContentRightConstraint.deactivate()

        arrowImageView.snp_makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.trailing.equalTo(customContentView)

            valueLabelToArrowConstraint = $0.leading.greaterThanOrEqualTo(valueLabel.snp_trailing).offset(Constants.ValueToArrowOffset).constraint
        }

        valueLabelToArrowConstraint.deactivate()
    }
}
