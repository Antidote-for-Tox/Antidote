// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

class StaticTableSwitchCell: StaticTableBaseCell {
    private var valueChangedHandler: (Bool -> Void)?

    private var titleLabel: UILabel!
    private var accessibilityButton: UIButton!
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

        switchView.enabled = switchModel.enabled
        switchView.tintColor = theme.colorForType(.LinkText)
        switchView.on = switchModel.on

        valueChangedHandler = switchModel.valueChangedHandler
    }

    override func createViews() {
        super.createViews()

        titleLabel = UILabel()
        titleLabel.backgroundColor = UIColor.clearColor()
        customContentView.addSubview(titleLabel)

        accessibilityButton = UIButton()
        accessibilityButton.addTarget(self,
                                      action: #selector(StaticTableSwitchCell.accessibilityButtonPressed),
                                      forControlEvents: .TouchUpInside)
        customContentView.addSubview(accessibilityButton)

        switchView = UISwitch()
        switchView.addTarget(self, action: #selector(StaticTableSwitchCell.switchValueChanged), forControlEvents: .ValueChanged)
        customContentView.addSubview(switchView)
    }

    override func installConstraints() {
        super.installConstraints()

        titleLabel.snp_makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.leading.equalTo(customContentView)
        }

        accessibilityButton.snp_makeConstraints {
            $0.edges.equalTo(customContentView)
        }

        switchView.snp_makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.leading.greaterThanOrEqualTo(titleLabel.snp_trailing)
            $0.trailing.equalTo(customContentView)
        }
    }
}

// Accessibility
extension StaticTableSwitchCell {
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
            return switchView.accessibilityValue
        }
        set {}
    }

    override var accessibilityHint: String? {
        get {
            return switchView.accessibilityHint
        }
        set {}
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return switchView.accessibilityTraits
        }
        set {}
    }
}

extension StaticTableSwitchCell {
    func accessibilityButtonPressed() {
        if UIAccessibilityIsVoiceOverRunning() {
            switchView.on = !switchView.on
            switchValueChanged()
        }
    }

    func switchValueChanged() {
        valueChangedHandler?(switchView.on)
    }
}
