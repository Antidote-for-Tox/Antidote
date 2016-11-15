// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class AvatarManager {
    enum AvatarType: String {
        case Normal
        case Call
    }

    fileprivate let theme: Theme
    fileprivate let cache: NSCache<AnyObject, AnyObject>

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
    func avatarFromString(_ string: String, diameter: CGFloat, type: AvatarType = .Normal) -> UIImage {
        var string = string

        if string.isEmpty {
            string = "?"
        }

        let key = keyFromString(string, diameter: diameter, type: type)

        if let avatar = cache.object(forKey: key as AnyObject) as? UIImage {
            return avatar
        }

        let avatar = createAvatarFromString(string, diameter: diameter, type: type)
        cache.setObject(avatar, forKey: key as AnyObject)

        return avatar
    }
}

private extension AvatarManager {
    func keyFromString(_ string: String, diameter: CGFloat, type: AvatarType) -> String {
        return "\(string)-\(diameter)-\(type.rawValue)"
    }

    func createAvatarFromString(_ string: String, diameter: CGFloat, type: AvatarType) -> UIImage {
        let avatarString = avatarStringFromString(string)

        let label = UILabel()
        label.layer.borderWidth = 1.0
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.text = avatarString

        switch type {
            case .Normal:
                label.backgroundColor = theme.colorForType(.NormalBackground)
                label.layer.borderColor = theme.colorForType(.LinkText).cgColor
                label.textColor = theme.colorForType(.LinkText)
            case .Call:
                label.backgroundColor = .clear
                label.layer.borderColor = theme.colorForType(.CallButtonIconColor).cgColor
                label.textColor = theme.colorForType(.CallButtonIconColor)
        }

        var size: CGSize
        var fontSize = diameter

        repeat {
            fontSize -= 1

            let font = UIFont.antidoteFontWithSize(fontSize, weight: .light)
            size = avatarString.stringSizeWithFont(font)
        }
        while (max(size.width, size.height) > diameter)

        let frame = CGRect(x: 0, y: 0, width: diameter, height: diameter)

        label.font = UIFont.antidoteFontWithSize(fontSize * 0.6, weight: .light)
        label.layer.cornerRadius = frame.size.width / 2
        label.frame = frame

        return imageWithLabel(label)
    }

    func avatarStringFromString(_ string: String) -> String {
        guard !string.isEmpty else {
            return ""
        }

        // Avatar can have alphanumeric symbols and ? sign.
        let badSymbols = (CharacterSet.alphanumerics.inverted as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        badSymbols.removeCharacters(in: "?")

        let words = string.components(separatedBy: CharacterSet.whitespaces).map {
            $0.components(separatedBy: badSymbols as CharacterSet).joined(separator: "")
        }.filter {
            !$0.isEmpty
        }

        let result = words.map {
            $0.isEmpty ? "" : $0[0..<1]
        }.joined(separator: "")

        let numberOfLetters = min(2, result.characters.count)

        return result.uppercased()[0..<numberOfLetters]
    }

    func imageWithLabel(_ label: UILabel) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image!
    }
}
