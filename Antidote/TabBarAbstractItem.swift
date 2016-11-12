// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class TabBarAbstractItem: UIView {
    var selected: Bool = false
    var didTapHandler: (Void -> Void)?
}

// Accessibility
extension TabBarAbstractItem {
    override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set {}
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            var value = UIAccessibilityTraitButton

            if selected {
                value |= UIAccessibilityTraitSelected
            }

            return value
        }
        set {}
    }
}
