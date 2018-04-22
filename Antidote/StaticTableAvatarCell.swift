// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

private struct Constants {
    static let AvatarVerticalOffset = 10.0
}

class StaticTableAvatarCell: StaticTableBaseCell {
    fileprivate var didTapOnAvatar: ((StaticTableAvatarCell) -> Void)?

    fileprivate var button: UIButton!

    override func setupWithTheme(_ theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let avatarModel = model as? StaticTableAvatarCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        selectionStyle = .none

        button.isUserInteractionEnabled = avatarModel.userInteractionEnabled
        button.setImage(avatarModel.avatar, for: UIControlState())
        didTapOnAvatar = avatarModel.didTapOnAvatar
    }

    override func createViews() {
        super.createViews()

        button = UIButton()
        button.layer.cornerRadius = StaticTableAvatarCellModel.Constants.AvatarImageSize / 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(StaticTableAvatarCell.buttonPressed), for: .touchUpInside)
        customContentView.addSubview(button)
    }

    override func installConstraints() {
        super.installConstraints()

        button.snp.makeConstraints {
            $0.centerX.equalTo(customContentView)
            $0.top.equalTo(customContentView).offset(Constants.AvatarVerticalOffset)
            $0.bottom.equalTo(customContentView).offset(-Constants.AvatarVerticalOffset)
            $0.size.equalTo(StaticTableAvatarCellModel.Constants.AvatarImageSize)
        }
    }
}

// Accessibility
extension StaticTableAvatarCell {
    override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set {}
    }

    override var accessibilityLabel: String? {
        get {
            return String(localized: "accessibility_avatar_button_label")
        }
        set {}
    }

    override var accessibilityHint: String? {
        get {
            return button.isUserInteractionEnabled ? String(localized: "accessibility_avatar_button_hint") : nil
        }
        set {}
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            var traits = UIAccessibilityTraitImage

            if button.isUserInteractionEnabled {
                traits |= UIAccessibilityTraitButton
            }

            return traits
        }
        set {}
    }
}

extension StaticTableAvatarCell {
    @objc func buttonPressed() {
        didTapOnAvatar?(self)
    }
}
