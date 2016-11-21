// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

extension String {
    init(timeInterval: TimeInterval) {
        var timeInterval = timeInterval

        let hours = Int(timeInterval / 3600)
        timeInterval -= TimeInterval(hours * 3600)

        let minutes = Int(timeInterval / 60)
        timeInterval -= TimeInterval(minutes * 60)

        let seconds = Int(timeInterval)

        if hours > 0 {
            self.init(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        else {
            self.init(format: "%02d:%02d", minutes, seconds)
        }
    }

    init(localized: String, _ arguments: CVarArg...) {
        let format = NSLocalizedString(localized, tableName: nil, bundle: Bundle.main, value: "", comment: "")
        self.init(format: format, arguments: arguments)
    }

    init(localized: String, comment: String, _ arguments: CVarArg...) {
        let format = NSLocalizedString(localized, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
        self.init(format: format, arguments: arguments)
    }

    func substringToByteLength(_ length: Int, encoding: String.Encoding) -> String {
        guard length > 0 else {
            return ""
        }

        var substring = self as NSString

        while substring.lengthOfBytes(using: encoding.rawValue) > length {
            let newLength = substring.length - 1

            guard newLength > 0 else {
                return ""
            }

            substring = substring.substring(to: newLength) as NSString
        }

        return substring as String
    }

    func stringSizeWithFont(_ font: UIFont) -> CGSize {
        return stringSizeWithFont(font, constrainedToSize:CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
    }

    func stringSizeWithFont(_ font: UIFont, constrainedToSize size: CGSize) -> CGSize {
        let boundingRect = (self as NSString).boundingRect(
            with: size,
            options: .usesLineFragmentOrigin,
            attributes: [NSFontAttributeName : font],
            context: nil)

        return CGSize(width: ceil(boundingRect.size.width), height: ceil(boundingRect.size.height))
    }

    subscript(range: Range<Int>) -> String {
        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) ?? endIndex))
    }
}
