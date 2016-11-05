// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

private struct Constants {
    static let VerticalOffset = 12.0
}

class StaticTableButtonCell: StaticTableBaseCell {
    private var label: UILabel!

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let buttonModel = model as? StaticTableButtonCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        label.text = buttonModel.title
        label.textColor = theme.colorForType(.LinkText)
    }

    override func createViews() {
        super.createViews()

        label = UILabel()
        customContentView.addSubview(label)
    }

    override func installConstraints() {
        super.installConstraints()

        label.snp_makeConstraints {
            $0.leading.trailing.equalTo(customContentView)
            $0.top.equalTo(customContentView).offset(Constants.VerticalOffset)
            $0.bottom.equalTo(customContentView).offset(-Constants.VerticalOffset)
        }
    }
}

// Accessibility
extension StaticTableButtonCell {
    override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set {}
    }

    override var accessibilityLabel: String? {
        get {
            return label.text
        }
        set {}
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return UIAccessibilityTraitButton
        }
        set {}
    }
}
