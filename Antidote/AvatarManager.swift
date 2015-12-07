//
//  AvatarManager.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import Foundation

class AvatarManager {
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
          - string: String to create avatar from.
          - diameter: Diameter of circle with avatar

        - Returns: Avatar from given string with given size.
     */
    func avatarFromString(string: String, diameter: CGFloat) -> UIImage {
        let key = keyFromString(string, diameter: diameter)

        if let avatar = cache.objectForKey(key) as? UIImage {
            return avatar
        }

        let avatar = createAvatarFromString(string, diameter: diameter)
        cache.setObject(avatar, forKey: key)

        return avatar
    }
}

private extension AvatarManager {
    func keyFromString(string: String, diameter: CGFloat) -> String {
        return "\(string)-\(diameter)"
    }

    func createAvatarFromString(string: String, diameter: CGFloat) -> UIImage {
        let avatarString = avatarStringFromString(string)

        let label = UILabel()
        label.backgroundColor = theme.colorForType(.NormalBackground)
        label.layer.borderColor = theme.colorForType(.NormalText).CGColor
        label.layer.borderWidth = 1.0
        label.layer.masksToBounds = true
        label.textColor = theme.colorForType(.NormalText)
        label.textAlignment = .Center
        label.text = avatarString

        var size: CGSize
        var fontSize = diameter

        repeat {
            fontSize--

            let font = UIFont.systemFontOfSize(fontSize, weight: UIFontWeightLight)
            size = avatarString.stringSizeWithFont(font)
        }
        while (max(size.width, size.height) > diameter)

        let frame = CGRect(x: 0, y: 0, width: diameter, height: diameter)

        label.font = UIFont.systemFontOfSize(fontSize * 0.6, weight: UIFontWeightLight)
        label.layer.cornerRadius = frame.size.width / 2
        label.frame = frame

        return imageWithLabel(label)
    }

    func avatarStringFromString(string: String) -> String {
        guard string.length > 0 else {
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
