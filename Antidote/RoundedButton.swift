// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

private struct Constants {
    static let Height = 40.0
}

class RoundedButton: UIButton {
    enum ButtonType {
        case login
        case runningPositive
        case runningNegative
    }

    init(theme: Theme, type: ButtonType) {
        super.init(frame: CGRect.zero)

        let titleColor: UIColor
        let bgColor: UIColor

        switch type {
            case .login:
                titleColor = theme.colorForType(.LoginButtonText)
                bgColor = theme.colorForType(.LoginButtonBackground)
            case .runningPositive:
                titleColor = theme.colorForType(.RoundedButtonText)
                bgColor = theme.colorForType(.RoundedPositiveButtonBackground)
            case .runningNegative:
                titleColor = theme.colorForType(.RoundedButtonText)
                bgColor = theme.colorForType(.RoundedNegativeButtonBackground)
        }

        setTitleColor(titleColor, for:UIControlState())
        titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        layer.cornerRadius = 5.0
        layer.masksToBounds = true

        let bgImage = UIImage.imageWithColor(bgColor, size: CGSize(width: 1.0, height: 1.0))
        setBackgroundImage(bgImage, for:UIControlState())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize : CGSize {
        return CGSize(width: 0.0, height: Constants.Height)
    }
}
