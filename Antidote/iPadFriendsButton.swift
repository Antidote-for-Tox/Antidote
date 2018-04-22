// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

private struct Constants {
    static let BadgeHorizontalOffset = 5.0
    static let BadgeMinimumWidth = 22.0
    static let BadgeHeight: CGFloat = 18.0
    static let BadgeRightOffset = -10.0
}

class iPadFriendsButton: UIView {
    var didTapHandler: (() -> Void)?

    var badgeText: String? {
        didSet {
            badgeLabel.text = badgeText
            badgeContainer.isHidden = (badgeText == nil)
        }
    }

    fileprivate var badgeContainer: UIView!
    fileprivate var badgeLabel: UILabel!
    fileprivate var button: UIButton!

    init(theme: Theme) {
        super.init(frame: CGRect.zero)

        createViews(theme)
        installConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension iPadFriendsButton {
    @objc func buttonPressed() {
        didTapHandler?()
    }
}

private extension iPadFriendsButton {
    func createViews(_ theme: Theme) {
        badgeContainer = UIView()
        badgeContainer.backgroundColor = theme.colorForType(.TabBadgeBackground)
        badgeContainer.layer.masksToBounds = true
        badgeContainer.layer.cornerRadius = Constants.BadgeHeight / 2
        addSubview(badgeContainer)

        badgeLabel = UILabel()
        badgeLabel.textColor = theme.colorForType(.TabBadgeText)
        badgeLabel.textAlignment = .center
        badgeLabel.backgroundColor = .clear
        badgeLabel.font = UIFont.antidoteFontWithSize(14.0, weight: .light)
        badgeContainer.addSubview(badgeLabel)

        button = UIButton(type: .system)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets.left = 20.0
        button.titleEdgeInsets.left = 20.0
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        button.setTitle(String(localized: "contacts_title"), for: UIControlState())
        button.setImage(UIImage(named: "tab-bar-friends"), for: UIControlState())
        button.addTarget(self, action: #selector(iPadFriendsButton.buttonPressed), for: .touchUpInside)
        addSubview(button)
    }

    func installConstraints() {
        badgeContainer.snp.makeConstraints {
            $0.trailing.equalTo(self).offset(Constants.BadgeRightOffset)
            $0.centerY.equalTo(self)
            $0.width.greaterThanOrEqualTo(Constants.BadgeMinimumWidth)
            $0.height.equalTo(Constants.BadgeHeight)
        }

        badgeLabel.snp.makeConstraints {
            $0.leading.equalTo(badgeContainer).offset(Constants.BadgeHorizontalOffset)
            $0.trailing.equalTo(badgeContainer).offset(-Constants.BadgeHorizontalOffset)
            $0.centerY.equalTo(badgeContainer)
        }

        button.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
    }
}
