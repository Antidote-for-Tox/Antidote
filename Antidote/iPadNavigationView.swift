// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

private struct Constants {
    static let Width = 200.0
    static let Height = 34.0
    static let Offset = 12.0
}

class iPadNavigationView: UIView {
    var avatarView: ImageViewWithStatus!
    var label: UILabel!

    var didTapHandler: ((Void) -> Void)?

    fileprivate var button: UIButton!

    init(theme: Theme) {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: Constants.Width, height: Constants.Height))

        createViews(theme)
        installConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension iPadNavigationView {
    func buttonPressed() {
        didTapHandler?()
    }
}

private extension iPadNavigationView {
    func createViews(_ theme: Theme) {
        avatarView = ImageViewWithStatus()
        avatarView.userStatusView.theme = theme
        addSubview(avatarView)

        label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22.0)
        addSubview(label)

        button = UIButton()
        button.addTarget(self, action: #selector(iPadNavigationView.buttonPressed), for: .touchUpInside)
        addSubview(button)
    }

    func installConstraints() {
        avatarView.snp.makeConstraints {
            $0.top.equalTo(self)
            $0.leading.equalTo(self)
            $0.size.equalTo(Constants.Height)
        }

        label.snp.makeConstraints {
            $0.leading.equalTo(avatarView.snp.trailing).offset(Constants.Offset)
            $0.trailing.equalTo(self)
            $0.top.equalTo(self)
            $0.bottom.equalTo(self)
        }

        button.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
    }
}
