// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

extension String {
    init(timeInterval: NSTimeInterval) {
        var timeInterval = timeInterval

        let hours = Int(timeInterval / 3600)
        timeInterval -= NSTimeInterval(hours * 3600)

        let minutes = Int(timeInterval / 60)
        timeInterval -= NSTimeInterval(minutes * 60)

        let seconds = Int(timeInterval)

        if hours > 0 {
            self.init(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        else {
            self.init(format: "%02d:%02d", minutes, seconds)
        }
    }

    init(localized: String, _ arguments: CVarArgType...) {
        let format = NSLocalizedString(localized, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
        self.init(format: format, arguments: arguments)
    }

    init(localized: String, comment: String, _ arguments: CVarArgType...) {
        let format = NSLocalizedString(localized, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: comment)
        self.init(format: format, arguments: arguments)
    }

    func substringToByteLength(length: Int, encoding: NSStringEncoding) -> String {
        guard length > 0 else {
            return ""
        }

        var substring = self as NSString

        while substring.lengthOfBytesUsingEncoding(encoding) > length {
            let newLength = substring.length - 1

            guard newLength > 0 else {
                return ""
            }

            substring = substring.substringToIndex(newLength)
        }

        return substring as String
    }

    func stringSizeWithFont(font: UIFont) -> CGSize {
        return stringSizeWithFont(font, constrainedToSize:CGSize(width: CGFloat.max, height: CGFloat.max))
    }

    func stringSizeWithFont(font: UIFont, constrainedToSize size: CGSize) -> CGSize {
        let boundingRect = (self as NSString).boundingRectWithSize(
            size,
            options: .UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName : font],
            context: nil)

        return CGSize(width: ceil(boundingRect.size.width), height: ceil(boundingRect.size.height))
    }

    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[start ..< end]
    }
}
