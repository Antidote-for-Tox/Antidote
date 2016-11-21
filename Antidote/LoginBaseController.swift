// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

class LoginBaseController: KeyboardNotificationController {
    struct Constants {
        static let HorizontalOffset = 40.0
        static let VerticalOffset = 40.0
        static let SmallVerticalOffset = 8.0

        static let TextFieldHeight: CGFloat = 40.0

        static let MaxFormWidth = 350.0

        static let GradientHeightPercentage: CGFloat = 0.4
    }

    let theme: Theme

    fileprivate var gradientLayer: CAGradientLayer!

    init(theme: Theme) {
        self.theme = theme

        super.init()

        edgesForExtendedLayout = UIRectEdge()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.LoginBackground))

        createGradientLayer()
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        gradientLayer.frame.size.width = view.frame.size.width
        gradientLayer.frame.size.height = view.frame.size.height * Constants.GradientHeightPercentage
        gradientLayer.frame.origin.x = 0
        gradientLayer.frame.origin.y = view.frame.size.height - gradientLayer.frame.size.height
    }
}

private extension LoginBaseController {
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [theme.colorForType(.LoginBackground).cgColor, theme.colorForType(.LoginGradient).cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
