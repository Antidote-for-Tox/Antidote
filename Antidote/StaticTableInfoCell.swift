// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

private struct Constants {
    static let ValueToArrowOffset = 6.0
}

class StaticTableInfoCell: StaticTableBaseCell {
    fileprivate var valueChangedHandler: ((Bool) -> Void)?

    fileprivate var titleLabel: UILabel!
    fileprivate var valueLabel: UILabel!
    fileprivate var arrowImageView: UIImageView!

    fileprivate var valueLabelToContentRightConstraint: Constraint!
    fileprivate var valueLabelToArrowConstraint: Constraint!

    override func setupWithTheme(_ theme: Theme, model: BaseCellModel) {
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
            arrowImageView.isHidden = false
            valueLabelToContentRightConstraint.deactivate()
            valueLabelToArrowConstraint.activate()
            selectionStyle = .default
        }
        else {
            arrowImageView.isHidden = true
            valueLabelToArrowConstraint.deactivate()
            valueLabelToContentRightConstraint.activate()
            selectionStyle = .none
        }
    }

    override func createViews() {
        super.createViews()

        titleLabel = UILabel()
        titleLabel.backgroundColor = UIColor.clear
        customContentView.addSubview(titleLabel)

        valueLabel = UILabel()
        valueLabel.backgroundColor = UIColor.clear
        customContentView.addSubview(valueLabel)

        arrowImageView = UIImageView()
        arrowImageView.image = UIImage(named: "right-arrow")!.flippedToCorrectLayout()
        customContentView.addSubview(arrowImageView)
    }

    override func installConstraints() {
        super.installConstraints()

        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.leading.equalTo(customContentView)
        }

        valueLabel.snp.makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing)
            valueLabelToContentRightConstraint = $0.trailing.equalTo(customContentView).constraint
        }

        valueLabelToContentRightConstraint.deactivate()

        arrowImageView.snp.makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.trailing.equalTo(customContentView)

            valueLabelToArrowConstraint = $0.leading.greaterThanOrEqualTo(valueLabel.snp.trailing).offset(Constants.ValueToArrowOffset).constraint
        }

        valueLabelToArrowConstraint.deactivate()
    }
}

// Accessibility
extension StaticTableInfoCell {
    override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set {}
    }

    override var accessibilityLabel: String? {
        get {
            return titleLabel.text
        }
        set {}
    }

    override var accessibilityValue: String? {
        get {
            return valueLabel.text
        }
        set {}
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return arrowImageView.isHidden ? UIAccessibilityTraitStaticText : UIAccessibilityTraitButton
        }
        set {}
    }
}
