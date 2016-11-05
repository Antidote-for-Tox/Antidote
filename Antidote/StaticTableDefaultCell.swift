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
    private var userStatusView: UserStatusView!
    private var titleLabel: UILabel!
    private var valueLabel: CopyLabel!
    private var rightButton: UIButton!
    private var rightImageView: UIImageView!

    private var userStatusViewVisibleConstraint: Constraint!
    private var userStatusViewHiddenConstraint: Constraint!

    private var valueLabelToTitleConstraint: Constraint!
    private var valueLabelToContentTopConstraint: Constraint!

    private var valueLabelToArrowConstraint: Constraint!
    private var valueLabelToContentRightConstraint: Constraint!

    private var rightButtonHandler: (Void -> Void)?

    private var checkmarkSelected: Bool = false

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let defaultModel = model as? StaticTableDefaultCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        if let userStatus = defaultModel.userStatus {
            userStatusView.theme = theme
            userStatusView.userStatus = userStatus
            userStatusView.hidden = false

            userStatusViewHiddenConstraint.deactivate()
            userStatusViewVisibleConstraint.activate()
        }
        else {
            userStatusView.hidden = true

            userStatusViewVisibleConstraint.deactivate()
            userStatusViewHiddenConstraint.activate()
        }

        titleLabel.textColor = theme.colorForType(.LinkText)
        valueLabel.textColor = theme.colorForType(.NormalText)
        rightButton.setTitleColor(theme.colorForType(.LinkText), forState: .Normal)

        titleLabel.text = defaultModel.title
        valueLabel.text = defaultModel.value
        valueLabel.copyable = defaultModel.canCopyValue

        rightButton.hidden = (defaultModel.rightButton == nil)
        rightButton.setTitle(defaultModel.rightButton, forState: .Normal)
        rightButtonHandler = defaultModel.rightButtonHandler

        let showRightImageView: Bool
        switch defaultModel.rightImageType {
            case .None:
                showRightImageView = false
                checkmarkSelected = false
            case .Arrow:
                showRightImageView = true
                rightImageView.image = UIImage(named: "right-arrow")!.flippedToCorrectLayout()
                checkmarkSelected = false
            case .Checkmark:
                showRightImageView = true
                rightImageView.image = UIImage(named: "checkmark")!
                checkmarkSelected = true
        }

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

        if showRightImageView {
            rightImageView.hidden = false

            valueLabelToContentRightConstraint.deactivate()
            valueLabelToArrowConstraint.activate()
        }
        else {
            rightImageView.hidden = true

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
        titleLabel.font = UIFont.antidoteFontWithSize(17.0, weight: .Light)
        titleLabel.backgroundColor = UIColor.clearColor()
        customContentView.addSubview(titleLabel)

        valueLabel = CopyLabel()
        valueLabel.numberOfLines = 0
        valueLabel.font = UIFont.systemFontOfSize(17.0)
        valueLabel.backgroundColor = UIColor.clearColor()
        customContentView.addSubview(valueLabel)

        rightButton = UIButton()
        rightButton.addTarget(self, action: #selector(StaticTableDefaultCell.rightButtonPressed), forControlEvents: .TouchUpInside)
        customContentView.addSubview(rightButton)

        rightImageView = UIImageView()
        customContentView.addSubview(rightImageView)
    }

    override func installConstraints() {
        super.installConstraints()

        userStatusView.snp_makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.leading.equalTo(customContentView)
            $0.size.equalTo(UserStatusView.Constants.DefaultSize)
        }

        titleLabel.snp_makeConstraints {
            $0.top.equalTo(customContentView).offset(Constants.EdgesVerticalOffset)
            $0.height.equalTo(Constants.TitleHeight)

            userStatusViewVisibleConstraint = $0.leading.equalTo(userStatusView.snp_trailing).offset(Constants.TitleToUserStatusOffset).constraint
        }

        userStatusViewVisibleConstraint.deactivate()

        titleLabel.snp_makeConstraints {
            userStatusViewHiddenConstraint = $0.leading.equalTo(customContentView).constraint
        }

        valueLabel.snp_makeConstraints {
            valueLabelToTitleConstraint = $0.top.equalTo(titleLabel.snp_bottom).offset(Constants.TitleToValueOffset).constraint

            valueLabelToContentRightConstraint = $0.trailing.equalTo(customContentView).constraint

            $0.leading.equalTo(titleLabel)
            $0.bottom.equalTo(customContentView).offset(-Constants.EdgesVerticalOffset)
            $0.height.greaterThanOrEqualTo(Constants.MinValueLabelHeight)
        }

        valueLabelToTitleConstraint.deactivate()
        valueLabel.snp_updateConstraints{ (make) -> Void in
            valueLabelToContentTopConstraint = make.top.equalTo(customContentView).offset(Constants.EdgesVerticalOffset).constraint
        }

        rightButton.snp_makeConstraints {
            $0.leading.greaterThanOrEqualTo(titleLabel.snp_trailing)
            $0.trailing.equalTo(customContentView)
            $0.centerY.equalTo(titleLabel)
            $0.bottom.lessThanOrEqualTo(customContentView)
        }

        rightImageView.snp_makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.trailing.equalTo(customContentView)

            valueLabelToArrowConstraint = $0.leading.greaterThanOrEqualTo(valueLabel.snp_trailing).constraint
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

            if selectionStyle == .None {
                return nil
            }

            return String(localized: "accessibility_edit_value_hint")
        }
        set {}
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            if selectionStyle == .None {
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
