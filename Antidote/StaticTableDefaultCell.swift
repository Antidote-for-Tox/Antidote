//
//  StaticTableDefaultCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 08/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let EdgesVerticalOffset = 10.0
    static let TitleHeight = 20.0
    static let TitleToValueOffset = 2.0
    static let MinValueLabelHeight = 20.0
}

class StaticTableDefaultCell: StaticTableBaseCell {
    private var titleLabel: UILabel!
    private var valueLabel: UILabel!
    private var rightButton: UIButton!
    private var arrowImageView: UIImageView!

    private var valueLabelToTitleConstraint: Constraint!
    private var valueLabelToContentTopConstraint: Constraint!

    private var valueLabelToArrowConstraint: Constraint!
    private var valueLabelToContentRightConstraint: Constraint!

    private var rightButtonHandler: (Void -> Void)?

    override func setupWithTheme(theme: Theme, model: StaticTableBaseModel) {
        super.setupWithTheme(theme, model: model)

        guard let defaultModel = model as? StaticTableDefaultModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        titleLabel.textColor = theme.colorForType(.LinkText)
        valueLabel.textColor = theme.colorForType(.NormalText)
        rightButton.setTitleColor(theme.colorForType(.LinkText), forState: .Normal)

        titleLabel.text = defaultModel.title
        valueLabel.text = defaultModel.value

        rightButton.hidden = (defaultModel.rightButton == nil)
        rightButton.setTitle(defaultModel.rightButton, forState: .Normal)
        rightButtonHandler = defaultModel.rightButtonHandler

        arrowImageView.hidden = !defaultModel.showArrow

        if defaultModel.userInteractionEnabled {
            selectionStyle = .Default
        }
        else {
            selectionStyle = .None
        }

        if defaultModel.title != nil {
            valueLabelToContentTopConstraint.deactivate()
            valueLabelToTitleConstraint.activate()
        }
        else {
            valueLabelToTitleConstraint.deactivate()
            valueLabelToContentTopConstraint.activate()
        }

        if defaultModel.showArrow {
            valueLabelToContentRightConstraint.deactivate()
            valueLabelToArrowConstraint.activate()
        }
        else {
            valueLabelToArrowConstraint.deactivate()
            valueLabelToContentRightConstraint.activate()
        }
    }

    override func createViews() {
        super.createViews()

        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFontOfSize(17.0, weight: UIFontWeightLight)
        titleLabel.backgroundColor = UIColor.clearColor()
        customContentView.addSubview(titleLabel)

        valueLabel = UILabel()
        valueLabel.numberOfLines = 0
        valueLabel.font = UIFont.systemFontOfSize(17.0, weight: UIFontWeightRegular)
        valueLabel.backgroundColor = UIColor.clearColor()
        customContentView.addSubview(valueLabel)

        rightButton = UIButton()
        rightButton.addTarget(self, action: "rightButtonPressed", forControlEvents: .TouchUpInside)
        customContentView.addSubview(rightButton)

        let image = UIImage(named: "right-arrow")!
        arrowImageView = UIImageView(image: image)
        customContentView.addSubview(arrowImageView)
    }

    override func installConstraints() {
        super.installConstraints()

        titleLabel.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(customContentView).offset(Constants.EdgesVerticalOffset)
            make.left.equalTo(customContentView)
            make.height.equalTo(Constants.TitleHeight)
        }

        valueLabel.snp_makeConstraints{ (make) -> Void in
            valueLabelToTitleConstraint = make.top.equalTo(titleLabel.snp_bottom).offset(Constants.TitleToValueOffset).constraint

            valueLabelToContentRightConstraint = make.right.equalTo(customContentView).constraint

            make.left.equalTo(customContentView)
            make.bottom.equalTo(customContentView).offset(-Constants.EdgesVerticalOffset)
            make.height.greaterThanOrEqualTo(Constants.MinValueLabelHeight)
        }

        valueLabelToTitleConstraint.deactivate()
        valueLabel.snp_updateConstraints{ (make) -> Void in
            valueLabelToContentTopConstraint = make.top.equalTo(customContentView).offset(Constants.EdgesVerticalOffset).constraint
        }

        rightButton.snp_makeConstraints{ (make) -> Void in
            make.left.greaterThanOrEqualTo(titleLabel.snp_right)
            make.right.equalTo(customContentView)
            make.centerY.equalTo(titleLabel)
            make.bottom.lessThanOrEqualTo(customContentView)
        }

        arrowImageView.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(customContentView)
            make.right.equalTo(customContentView)

            valueLabelToArrowConstraint = make.left.greaterThanOrEqualTo(valueLabel).constraint
        }
    }
}

extension StaticTableDefaultCell {
    func rightButtonPressed() {
        rightButtonHandler?()
    }
}
