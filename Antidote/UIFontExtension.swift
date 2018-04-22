// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

extension UIFont {
    enum AWeight {
        case light
        case medium
        case bold

        func w() -> UIFont.Weight {
            if #available(iOS 8.2, *) {
                switch self {
                    case .light:
                        return UIFont.Weight.light
                    case .medium:
                        return UIFont.Weight.medium
                    case .bold:
                        return UIFont.Weight.bold
                }
            }

            return UIFont.Weight(0.0)
        }

        func name() -> String {
            switch self {
                case .light:
                    return "HelveticaNeue-Light"
                case .medium:
                    return "HelveticaNeue-Medium"
                case .bold:
                    return "HelveticaNeue-Bold"
            }
        }
    }

    class func antidoteFontWithSize(_ size: CGFloat, weight: AWeight) -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: size, weight: weight.w())
        } else {
            return UIFont(name: weight.name(), size: size)!
        }
    }
}
