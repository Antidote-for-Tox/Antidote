// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

class StaticTableSwitchCell: StaticTableBaseCell {
    fileprivate var valueChangedHandler: ((Bool) -> Void)?

    fileprivate var titleLabel: UILabel!
    fileprivate var accessibilityButton: UIButton!
    fileprivate var switchView: UISwitch!

    override func setupWithTheme(_ theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let switchModel = model as? StaticTableSwitchCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        selectionStyle = .none

        titleLabel.textColor = theme.colorForType(.NormalText)
        titleLabel.text = switchModel.title

        switchView.isEnabled = switchModel.enabled
        switchView.tintColor = theme.colorForType(.LinkText)
        switchView.isOn = switchModel.on

        valueChangedHandler = switchModel.valueChangedHandler
    }

    override func createViews() {
        super.createViews()

        titleLabel = UILabel()
        titleLabel.backgroundColor = UIColor.clear
        customContentView.addSubview(titleLabel)

        accessibilityButton = UIButton()
        accessibilityButton.addTarget(self,
                                      action: #selector(StaticTableSwitchCell.accessibilityButtonPressed),
                                      for: .touchUpInside)
        customContentView.addSubview(accessibilityButton)

        switchView = UISwitch()
        switchView.addTarget(self, action: #selector(StaticTableSwitchCell.switchValueChanged), for: .valueChanged)
        customContentView.addSubview(switchView)
    }

    override func installConstraints() {
        super.installConstraints()

        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.leading.equalTo(customContentView)
        }

        accessibilityButton.snp.makeConstraints {
            $0.edges.equalTo(customContentView)
        }

        switchView.snp.makeConstraints {
            $0.centerY.equalTo(customContentView)
            $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing)
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
            switchView.isOn = !switchView.isOn
            switchValueChanged()
        }
    }

    func switchValueChanged() {
        valueChangedHandler?(switchView.isOn)
    }
}
