// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class AvatarManager {
    enum Type: String {
        case Normal
        case Call
    }

    private let theme: Theme
    private let cache: NSCache

    init(theme: Theme) {
        self.theme = theme
        self.cache = NSCache()
    }

    /**
        Returns round avatar created from string with a given diameter. Searches for an avatar in cache first,
        if not found creates it.

        - Parameters:
          - string: String to create avatar from. In case of empty string avatar will be set to "?".
          - diameter: Diameter of circle with avatar.

        - Returns: Avatar from given string with given size.
     */
    func avatarFromString(string: String, diameter: CGFloat, type: Type = .Normal) -> UIImage {
        var string = string

        if string.isEmpty {
            string = "?"
        }

        let key = keyFromString(string, diameter: diameter, type: type)

        if let avatar = cache.objectForKey(key) as? UIImage {
            return avatar
        }

        let avatar = createAvatarFromString(string, diameter: diameter, type: type)
        cache.setObject(avatar, forKey: key)

        return avatar
    }
}

private extension AvatarManager {
    func keyFromString(string: String, diameter: CGFloat, type: Type) -> String {
        return "\(string)-\(diameter)-\(type.rawValue)"
    }

    func createAvatarFromString(string: String, diameter: CGFloat, type: Type) -> UIImage {
        let avatarString = avatarStringFromString(string)

        let label = UILabel()
        label.layer.borderWidth = 1.0
        label.layer.masksToBounds = true
        label.textAlignment = .Center
        label.text = avatarString

        switch type {
            case .Normal:
                label.backgroundColor = theme.colorForType(.NormalBackground)
                label.layer.borderColor = theme.colorForType(.LinkText).CGColor
                label.textColor = theme.colorForType(.LinkText)
            case .Call:
                label.backgroundColor = .clearColor()
                label.layer.borderColor = theme.colorForType(.CallButtonIconColor).CGColor
                label.textColor = theme.colorForType(.CallButtonIconColor)
        }

        var size: CGSize
        var fontSize = diameter

        repeat {
            fontSize--

            let font = UIFont.antidoteFontWithSize(fontSize, weight: .Light)
            size = avatarString.stringSizeWithFont(font)
        }
        while (max(size.width, size.height) > diameter)

        let frame = CGRect(x: 0, y: 0, width: diameter, height: diameter)

        label.font = UIFont.antidoteFontWithSize(fontSize * 0.6, weight: .Light)
        label.layer.cornerRadius = frame.size.width / 2
        label.frame = frame

        return imageWithLabel(label)
    }

    func avatarStringFromString(string: String) -> String {
        guard !string.isEmpty else {
            return ""
        }

        // Avatar can have alphanumeric symbols and ? sign.
        let badSymbols = NSCharacterSet.alphanumericCharacterSet().invertedSet.mutableCopy() as! NSMutableCharacterSet
        badSymbols.removeCharactersInString("?")

        let words = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).map {
            $0.componentsSeparatedByCharactersInSet(badSymbols).joinWithSeparator("")
        }.filter {
            !$0.isEmpty
        }

        let result = words.map {
            $0.isEmpty ? "" : $0[0..<1]
        }.joinWithSeparator("")

        let numberOfLetters = min(2, result.characters.count)

        return result.uppercaseString[0..<numberOfLetters]
    }

    func imageWithLabel(label: UILabel) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.renderInContext(UIGraphicsGetCurrentContext()!)

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image
    }
}
