// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

extension UIViewController {
    func loadViewWithBackgroundColor(_ backgroundColor: UIColor) {
        let frame = CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size)

        view = UIView(frame: frame)
        view.backgroundColor = backgroundColor
    }
}
