// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

/**
    View with static background color. Is used to prevent views inside UITableViewCell from blinking on tap.
 */
class StaticBackgroundView: UIView {
    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {}
    }

    func setStaticBackgroundColor(_ color: UIColor?) {
        super.backgroundColor = color
    }
}
