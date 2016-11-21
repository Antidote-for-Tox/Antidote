// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

extension DateFormatter {
    enum FormatterType {
        case time
        case dateAndTime
        case relativeDate
        case relativeDateAndTime
    }

    convenience init(type: FormatterType) {
        self.init()

        switch type {
            case .time:
                dateFormat = "H:mm"
            case .dateAndTime:
                dateStyle = .short
                timeStyle = .short
                doesRelativeDateFormatting = false
            case .relativeDate:
                dateStyle = .short
                timeStyle = .none
                doesRelativeDateFormatting = true
            case .relativeDateAndTime:
                dateStyle = .short
                timeStyle = .short
                doesRelativeDateFormatting = true
        }
    }
}
