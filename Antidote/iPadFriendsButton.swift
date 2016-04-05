//
//  iPadFriendsButton.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 28.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let BadgeHorizontalOffset = 5.0
    static let BadgeMinimumWidth = 22.0
    static let BadgeHeight: CGFloat = 18.0
    static let BadgeRightOffset = -10.0
}

class iPadFriendsButton: UIView {
    var didTapHandler: (Void -> Void)?

    var badgeText: String? {
        didSet {
            badgeLabel.text = badgeText
            badgeContainer.hidden = (badgeText == nil)
        }
    }

    private var badgeContainer: UIView!
    private var badgeLabel: UILabel!
    private var button: UIButton!

    init(theme: Theme) {
        super.init(frame: CGRectZero)

        createViews(theme)
        installConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension iPadFriendsButton {
    func buttonPressed() {
        didTapHandler?()
    }
}

private extension iPadFriendsButton {
    func createViews(theme: Theme) {
        badgeContainer = UIView()
        badgeContainer.backgroundColor = theme.colorForType(.TabBadgeBackground)
        badgeContainer.layer.masksToBounds = true
        badgeContainer.layer.cornerRadius = Constants.BadgeHeight / 2
        addSubview(badgeContainer)

        badgeLabel = UILabel()
        badgeLabel.textColor = theme.colorForType(.TabBadgeText)
        badgeLabel.textAlignment = .Center
        badgeLabel.backgroundColor = .clearColor()
        badgeLabel.font = UIFont.antidoteFontWithSize(14.0, weight: .Light)
        badgeContainer.addSubview(badgeLabel)

        button = UIButton(type: .System)
        button.contentHorizontalAlignment = .Left
        button.contentEdgeInsets.left = 20.0
        button.titleEdgeInsets.left = 20.0
        button.titleLabel?.font = UIFont.systemFontOfSize(18.0)
        button.setTitle(String(localized: "contacts_title"), forState: .Normal)
        button.setImage(UIImage(named: "tab-bar-friends"), forState: .Normal)
        button.addTarget(self, action: #selector(iPadFriendsButton.buttonPressed), forControlEvents: .TouchUpInside)
        addSubview(button)
    }

    func installConstraints() {
        badgeContainer.snp_makeConstraints {
            $0.trailing.equalTo(self).offset(Constants.BadgeRightOffset)
            $0.centerY.equalTo(self)
            $0.width.greaterThanOrEqualTo(Constants.BadgeMinimumWidth)
            $0.height.equalTo(Constants.BadgeHeight)
        }

        badgeLabel.snp_makeConstraints {
            $0.leading.equalTo(badgeContainer).offset(Constants.BadgeHorizontalOffset)
            $0.trailing.equalTo(badgeContainer).offset(-Constants.BadgeHorizontalOffset)
            $0.centerY.equalTo(badgeContainer)
        }

        button.snp_makeConstraints {
            $0.edges.equalTo(self)
        }
    }
}
