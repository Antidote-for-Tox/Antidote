//
//  Theme.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 08/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import Yaml

enum ErrorTheme: ErrorType {
    case CannotParseFile
    case VersionTooLow
    case VersionTooHigh
}

class Theme {
    enum Type: String {
        case LoginBackground = "login-background"
        case LoginButtonText = "login-button-text"

        // Because enums don't support enumerations we have to do this hack. Phew.
        static let allValues = [LoginBackground, LoginButtonText]
    }

    init(yamlString: String) throws {
        guard let dictionary = Yaml.load(yamlString).value?.dictionary else {
            throw ErrorTheme.CannotParseFile
        }

        try checkVersion(dictionary)

        mappedColors = try createMappedColors(fromDictionary: dictionary)
        try validateMappedColors(mappedColors)
    }

    func colorForType(type: Type) -> UIColor {
        return mappedColors[type.rawValue]!
    }

    private var mappedColors: [String: UIColor]!
}

private extension Theme {
    struct Constants {
        static let VersionValue = 1
        static let VersionKey = "version"
        static let ColorsKey = "colors"
        static let ValuesKey = "values"
    }

    func checkVersion(dictionary: [Yaml: Yaml]) throws {
        guard let version = dictionary[Yaml.String(Constants.VersionKey)]?.int else {
            throw ErrorTheme.CannotParseFile
        }

        guard version == Constants.VersionValue else {
            throw version > Constants.VersionValue ? ErrorTheme.VersionTooHigh : ErrorTheme.VersionTooLow
        }
    }

    func createMappedColors(fromDictionary dictionary: [Yaml: Yaml]) throws -> [String: UIColor] {
        let colorsDict = try parseDictionary(dictionary, forKey: Constants.ColorsKey) { (string: String) -> UIColor? in
            return UIColor(hexString: string)
        }
        let valuesDict = try parseDictionary(dictionary, forKey: Constants.ValuesKey) { (string: String) -> String? in
            return string
        }

        var mappedColors = [String: UIColor]()

        for (key, value) in valuesDict {
            guard let color = colorsDict[value] else {
                throw ErrorTheme.CannotParseFile
            }

            mappedColors[key] = color
        }

        return mappedColors
    }

    func parseDictionary<T>(dictionary: [Yaml: Yaml], forKey key: String, modifyValue: String -> T?) throws -> [String: T] {
        guard let yamlDict = dictionary[Yaml.String(key)]?.dictionary else {
            throw ErrorTheme.CannotParseFile
        }

        var resultDict = [String: T]()

        for (keyYaml, valueYaml) in yamlDict {
            guard let key = keyYaml.string,
                  let originalValue = valueYaml.string,
                  let valueToSet = modifyValue(originalValue) else {
                throw ErrorTheme.CannotParseFile
            }

            resultDict[key] = valueToSet
        }

        return resultDict
    }

    func validateMappedColors(dictionary: [String: UIColor]) throws {
        for type in Type.allValues {
            guard let _ = dictionary[type.rawValue] else {
                throw ErrorTheme.CannotParseFile
            }
        }
    }
}

private extension UIColor {
    convenience init?(hexString: String) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0

        guard let number = Int(hexString, radix: 16) else {
            return nil
        }

        switch(hexString.length) {
            case 6:
                red   = CGFloat((number & 0xFF0000) >> 16) / 255.0
                green = CGFloat((number & 0x00FF00) >> 8) / 255.0
                blue  = CGFloat((number & 0x0000FF) >> 0) / 255.0
            case 8:
                red   = CGFloat((number & 0xFF000000) >> 24) / 255.0
                green = CGFloat((number & 0x00FF0000) >> 16) / 255.0
                blue  = CGFloat((number & 0x0000FF00) >> 8) / 255.0
                alpha = CGFloat((number & 0x000000FF) >> 0) / 255.0
            default:
                return nil
        }

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

