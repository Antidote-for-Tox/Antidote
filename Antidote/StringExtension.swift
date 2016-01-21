//
//  StringExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 08/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import Foundation

extension String {
    init(timeInterval: NSTimeInterval) {
        let minutes = Int(timeInterval / 60)
        let seconds = Int(timeInterval) - minutes * 60

        self.init(format: "%02d:%02d", minutes, seconds)
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
            return self[Range(start: start, end: end)]
    }
}
