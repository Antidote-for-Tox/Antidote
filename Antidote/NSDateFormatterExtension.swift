// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

extension NSDateFormatter {
    enum Type {
        case Time
        case DateAndTime
        case RelativeDate
        case RelativeDateAndTime
    }

    convenience init(type: Type) {
        self.init()

        switch type {
            case .Time:
                dateFormat = "H:mm"
            case .DateAndTime:
                dateStyle = .ShortStyle
                timeStyle = .ShortStyle
                doesRelativeDateFormatting = false
            case .RelativeDate:
                dateStyle = .ShortStyle
                timeStyle = .NoStyle
                doesRelativeDateFormatting = true
            case .RelativeDateAndTime:
                dateStyle = .ShortStyle
                timeStyle = .ShortStyle
                doesRelativeDateFormatting = true
        }
    }
}
