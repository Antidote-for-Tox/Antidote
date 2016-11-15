// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

private struct Constants {
    static let EdgesVerticalOffset = 10.0
    static let TitleHeight = 20.0
    static let TitleToUserStatusOffset = 7.0
    static let TitleToValueOffset = 2.0
    static let MinValueLabelHeight = 20.0
}

class StaticTableDefaultCell: StaticTableBaseCell {
    fileprivate var userStatusView: UserStatusView!
    fileprivate var titleLabel: UILabel!
    fileprivate var valueLabel: CopyLabel!
    fileprivate var rightButton: UIButton!
    fileprivate var rightImageView: UIImageView!

    fileprivate var userStatusViewVisibleConstraint: Constraint!
    fileprivate var userStatusViewHiddenConstraint: Constraint!

    fileprivate var valueLabelToTitleConstraint: Constraint!
    fileprivate var valueLabelToContentTopConstraint: Constraint!

    fileprivate var valueLabelToArrowConstraint: Constraint!
    fileprivate var valueLabelToContentRightConstraint: Constraint!

    fileprivate var rightButtonHandler: ((Void) -> Void)?

    fileprivate var checkmarkSelected: Bool = false

    override func setupWithTheme(_ theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let defaultModel = model as? StaticTableDefaultCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        if let userStatus = defaultModel.userStatus {
            userStatusView.theme = theme
            userStatusView.userStatus = userStatus
            userStatusView.isHidden = false

            userStatusViewHiddenConstraint.deactivate()
            userStatusViewVisibleConstraint.activate()
        }
        else {
            userStatusView.isHidden = true

            userStatusViewVisibleConstraint.deactivate()
            userStatusViewHiddenConstraint.activate()
        }

        titleLabel.textColor = theme.colorForType(.LinkText)
        valueLabel.textColor = theme.colorForType(.NormalText)
        rightButton.setTitleColor(theme.colorForType(.LinkText), for: UIControlState())

        titleLabel.text = defaultModel.title
        valueLabel.text = defaultModel.value
        valueLabel.copyable = defaultModel.canCopyValue

        rightButton.isHidden = (defaultModel.rightButton == nil)
        rightButton.setTitle(defaultModel.rightButton, for: UIControlState())
        rightButtonHandler = defaultModel.rightButtonHandler

        let showRightImageView: Bool
        switch defaultModel.rightImageType {
            case .none:
                showRightImageView = false
                checkmarkSelected = false
            case .arrow:
                showRightImageView = true
                rightImageView.image = UIImage(named: "right-arrow")!.flippedToCorrectLayout()
                checkmarkSelected = false
            case .checkmark:
                showRightImageView = true
                rightImageView.image = UIImage(named: "checkmark")!
                checkmarkSelected = true
        }

        if defaultModel.userInteractionEnabled {
            selectionStyle = .default
        }
        else {
            selectionStyle = .none
        }

        if defaultModel.title != nil {
            valueLabelToContentTopConstraint.deactivate()
            valueLabelToTitleConstraint.activate()
        }
        else {
            valueLabelToTitleConstraint.deactivate()
            valueLabelToContentTopConstraint.activate()
        }

        if showRightImageView {
            rightImageView.isHidden = false

            valueLabelToContentRightConstraint.deactivate()
            valueLabelToArrowConstraint.activate()
        }
        else {
            rightImageView.isHidden = true

            valueLabelToArrowConstraint.deactivate()
            valueLabelToContentRightConstraint.activate()
        }
    }

    override func createViews() {
        super.createViews()

        userStatusView = UserStatusView()
        userStatusView.showExternalCircle = false
        customContentView.addSubview(userStatusView)

        titleLabel = UILabel()
        titleLabel.font = UIFont.antidoteFontWithSize(17.0, weight: .light)
        titleLabel.backgroundColor = UIColor.clear
        customContentView.addSubview(titleLabel)

        valueLabel = CopyLabel()
        valueLabel.numberOfLines = 0
        valueLabel.font = UIFont.systemFont(ofSize: 17.0)
        valueLabel.backgroundColor = UIColor.clear
        customContentView.addSubview(valueLabel)

        rightButton = UIButton()
        rightButton.addTarget(self, action: #selector(StaticTableDefaultCell.rightButtonPressed), for: .touchUpInside)
        customContentView.addSubview(rightButton)

        rightImageView = UIImageView()
        customContentView.addSubview(rightImageView)
    }

    override func installConstraints() {
        super.installConstraints()

        userStatusView.snp.makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.leading.equalTo(customContentView)
            $0.size.equalTo(UserStatusView.Constants.DefaultSize)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(customContentView).offset(Constants.EdgesVerticalOffset)
            $0.height.equalTo(Constants.TitleHeight)

            userStatusViewVisibleConstraint = $0.leading.equalTo(userStatusView.snp.trailing).offset(Constants.TitleToUserStatusOffset).constraint
        }

        userStatusViewVisibleConstraint.deactivate()

        titleLabel.snp.makeConstraints {
            userStatusViewHiddenConstraint = $0.leading.equalTo(customContentView).constraint
        }

        valueLabel.snp.makeConstraints {
            valueLabelToTitleConstraint = $0.top.equalTo(titleLabel.snp.bottom).offset(Constants.TitleToValueOffset).constraint

            valueLabelToContentRightConstraint = $0.trailing.equalTo(customContentView).constraint

            $0.leading.equalTo(titleLabel)
            $0.bottom.equalTo(customContentView).offset(-Constants.EdgesVerticalOffset)
            $0.height.greaterThanOrEqualTo(Constants.MinValueLabelHeight)
        }

        valueLabelToTitleConstraint.deactivate()
        valueLabel.snp.updateConstraints{ (make) -> Void in
            valueLabelToContentTopConstraint = make.top.equalTo(customContentView).offset(Constants.EdgesVerticalOffset).constraint
        }

        rightButton.snp.makeConstraints {
            $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing)
            $0.trailing.equalTo(customContentView)
            $0.centerY.equalTo(titleLabel)
            $0.bottom.lessThanOrEqualTo(customContentView)
        }

        rightImageView.snp.makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.trailing.equalTo(customContentView)

            valueLabelToArrowConstraint = $0.leading.greaterThanOrEqualTo(valueLabel.snp.trailing).constraint
        }
    }
}

// Accessibility
extension StaticTableDefaultCell {
    override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set {}
    }

    override var accessibilityLabel: String? {
        get {
            return titleLabel.text ?? valueLabel.text
        }
        set {}
    }

    override var accessibilityValue: String? {
        get {
            if titleLabel.text != nil {
                return valueLabel.text
            }

            return nil
        }
        set {}
    }

    override var accessibilityHint: String? {
        get {
            if valueLabel.copyable {
                return String(localized: "accessibility_show_copy_hint")
            }

            if selectionStyle == .none {
                return nil
            }

            return String(localized: "accessibility_edit_value_hint")
        }
        set {}
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            if selectionStyle == .none {
                return UIAccessibilityTraitStaticText
            }

            var traits = UIAccessibilityTraitButton

            if checkmarkSelected {
                traits |= UIAccessibilityTraitSelected
            }

            return traits
        }
        set {}
    }
}

extension StaticTableDefaultCell {
    func rightButtonPressed() {
        rightButtonHandler?()
    }
}
