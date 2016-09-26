//
//  UIFontExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 04.04.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit

extension UIFont {
    enum Weight {
        case Light
        case Medium
        case Bold

        func float() -> CGFloat {
            if #available(iOS 8.2, *) {
                switch self {
                    case .Light:
                        return UIFontWeightLight
                    case .Medium:
                        return UIFontWeightMedium
                    case .Bold:
                        return UIFontWeightBold
                }
            }

            return 0.0
        }

        func name() -> String {
            switch self {
                case .Light:
                    return "HelveticaNeue-Light"
                case .Medium:
                    return "HelveticaNeue-Medium"
                case .Bold:
                    return "HelveticaNeue-Bold"
            }
        }
    }

    class func antidoteFontWithSize(size: CGFloat, weight: Weight) -> UIFont {
        if #available(iOS 8.2, *) {
            return UIFont.systemFontOfSize(size, weight: weight.float())
        } else {
            return UIFont(name: weight.name(), size: size)!
        }
    }
}
