// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.


import SnapKit

private struct Constants {
    static let ImageSize = 32.0
}

class TabBarProfileItem: TabBarAbstractItem {
    override var selected: Bool {
        didSet {
            imageViewWithStatus.imageView.tintColor = theme.colorForType(selected ? .TabItemActive : .TabItemInactive)
        }
    }

    var userStatus: UserStatus = .offline {
        didSet {
            imageViewWithStatus.userStatusView.userStatus = userStatus
        }
    }

    var userImage: UIImage? {
        didSet {
            if let image = userImage {
                imageViewWithStatus.imageView.image = image
            }
            else {
                imageViewWithStatus.imageView.image = UIImage.templateNamed("tab-bar-profile")
            }
        }
    }

    fileprivate let theme: Theme

    fileprivate var imageViewWithStatus: ImageViewWithStatus!
    fileprivate var button: UIButton!

    init(theme: Theme) {
        self.theme = theme

        super.init(frame: CGRect.zero)

        backgroundColor = .clear

        createViews()
        installConstraints()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Accessibility
extension TabBarProfileItem {
    override var accessibilityLabel: String? {
        get {
            return String(localized: "profile_title")
        }
        set {}
    }

    override var accessibilityValue: String? {
        get {
            return userStatus.toString()
        }
        set {}
    }
}

// Actions
extension TabBarProfileItem {
    @objc func buttonPressed() {
        didTapHandler?()
    }
}

private extension TabBarProfileItem {
    func createViews() {
        imageViewWithStatus = ImageViewWithStatus()
        imageViewWithStatus.userStatusView.theme = theme
        addSubview(imageViewWithStatus)

        button = UIButton()
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(TabBarProfileItem.buttonPressed), for: .touchUpInside)
        addSubview(button)
    }

    func installConstraints() {
        imageViewWithStatus.snp.makeConstraints {
            $0.center.equalTo(self)
            $0.size.equalTo(Constants.ImageSize)
        }

        button.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
    }
}

