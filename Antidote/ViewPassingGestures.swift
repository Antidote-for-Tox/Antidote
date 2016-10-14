// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class ViewPassingGestures: UIView {
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        for subview in subviews {
            let converted = convertPoint(point, toView: subview)

            if subview.hitTest(converted, withEvent: event) != nil {
                return true
            }
        }

        return false
    }
}
