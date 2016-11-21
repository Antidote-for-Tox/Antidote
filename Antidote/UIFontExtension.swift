// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

extension UIFont {
    enum Weight {
        case light
        case medium
        case bold

        func float() -> CGFloat {
            if #available(iOS 8.2, *) {
                switch self {
                    case .light:
                        return UIFontWeightLight
                    case .medium:
                        return UIFontWeightMedium
                    case .bold:
                        return UIFontWeightBold
                }
            }

            return 0.0
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

    class func antidoteFontWithSize(_ size: CGFloat, weight: Weight) -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFont(ofSize: size, weight: weight.float())
        } else {
            return UIFont(name: weight.name(), size: size)!
        }
    }
}
