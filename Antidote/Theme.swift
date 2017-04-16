// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Yaml

enum ErrorTheme: Error {
    case cannotParseFile(String)
    case wrongVersion(String)

    func debugDescription() -> String {
        switch self {
            case .cannotParseFile(let string):
                return "Parse error: \(string)"
            case .wrongVersion(let string):
                return "Version error: \(string)"
        }
    }
}

class Theme {
    enum ColorType: String {
        case LoginBackground = "login-background"
        case LoginGradient = "login-gradient"
        case LoginToxLogo = "login-tox-logo"
        case LoginButtonText = "login-button-text"
        case LoginButtonBackground = "login-button-background"
        case LoginDescriptionLabel = "login-description-label"
        case LoginFormBackground = "login-form-background"
        case LoginFormText = "login-form-text"
        case LoginLinkColor = "login-link-color"

        case TranslucentBackground = "translucent-background"

        case NormalBackground = "normal-background"
        case NormalText = "normal-text"
        case LinkText = "link-text"
        case ConnectingBackground = "connecting-background"
        case ConnectingText = "connecting-text"
        case SeparatorsAndBorders = "separators-and-borders"
        case OfflineStatus = "offline-status"
        case OnlineStatus = "online-status"
        case AwayStatus = "away-status"
        case BusyStatus = "busy-status"
        case StatusBackground = "status-background"
        case FriendCellStatus = "friend-cell-status"
        case ChatListCellMessage = "chat-list-cell-message"
        case ChatListCellUnreadBackground = "chat-list-cell-unread-background"
        case ChatInputBackground = "chat-input-background"
        case ChatIncomingBubble = "chat-incoming-bubble"
        case ChatOutgoingBubble = "chat-outgoing-bubble"
        case ChatInformationText = "chat-information-text"
        case TabBadgeBackground = "tab-badge-background"
        case TabBadgeText = "tab-badge-text"
        case TabItemActive = "tab-item-active"
        case TabItemInactive = "tab-item-inactive"
        case NotificationBackground = "notification-background"
        case NotificationText = "notification-text"
        case SettingsBackground = "settings-background"
        case CallTextColor = "call-text-color"
        case CallDeclineButtonBackground = "call-decline-button-background"
        case CallAnswerButtonBackground = "call-answer-button-background"
        case CallControlSelectedBackground = "call-control-selected-background"
        case CallControlBackground = "call-control-background"
        case CallButtonIconColor = "call-button-icon-color"
        case CallButtonSelectedIconColor = "call-button-selected-icon-color"
        case CallVideoPreviewBackground = "call-video-preview-background"
        case RoundedButtonText = "rounded-button-text"
        case RoundedPositiveButtonBackground = "rounded-positive-button-background"
        case RoundedNegativeButtonBackground = "rounded-negative-button-background"
        case EmptyScreenPlaceholderText = "empty-screen-placeholder-text"
        case FileImageBackgroundActive = "file-image-background-active"
        case FileImageCancelledText = "file-image-cancelled-text"
        case FileImageAcceptButtonTint = "file-image-accept-button-tint"
        case FileImageCancelButtonTint = "file-image-cancel-button-tint"
        case LockGradientTop = "lock-gradient-top"
        case LockGradientBottom = "lock-gradient-bottom"

        // Because enums don't support enumerations we have to do this hack. Phew.
        static let allValues = [
            LoginBackground,
            LoginGradient,
            LoginToxLogo,
            LoginButtonText,
            LoginButtonBackground,
            LoginDescriptionLabel,
            LoginFormBackground,
            LoginFormText,
            LoginLinkColor,
            TranslucentBackground,
            NormalBackground,
            NormalText,
            LinkText,
            ConnectingBackground,
            ConnectingText,
            SeparatorsAndBorders,
            OfflineStatus,
            OnlineStatus,
            AwayStatus,
            BusyStatus,
            StatusBackground,
            FriendCellStatus,
            ChatListCellMessage,
            ChatListCellUnreadBackground,
            ChatInputBackground,
            ChatIncomingBubble,
            ChatOutgoingBubble,
            ChatInformationText,
            TabBadgeBackground,
            TabBadgeText,
            TabItemActive,
            TabItemInactive,
            NotificationBackground,
            NotificationText,
            SettingsBackground,
            CallTextColor,
            CallDeclineButtonBackground,
            CallAnswerButtonBackground,
            CallControlBackground,
            CallControlSelectedBackground,
            CallButtonIconColor,
            CallButtonSelectedIconColor,
            CallVideoPreviewBackground,
            RoundedButtonText,
            RoundedPositiveButtonBackground,
            RoundedNegativeButtonBackground,
            EmptyScreenPlaceholderText,
            FileImageBackgroundActive,
            FileImageCancelledText,
            FileImageAcceptButtonTint,
            FileImageCancelButtonTint,
            LockGradientTop,
            LockGradientBottom,
        ]
    }

    init(yamlString: String) throws {
        guard let dictionary = try Yaml.load(yamlString).dictionary else {
            throw ErrorTheme.cannotParseFile(String(localized:"theme_error_cannot_open"))
        }

        try checkVersion(dictionary)

        mappedColors = try createMappedColors(fromDictionary: dictionary)
        try validateMappedColors(mappedColors)
    }

    func colorForType(_ type: ColorType) -> UIColor {
        return mappedColors[type.rawValue]!
    }

    var loginNavigationBarColor: UIColor {
        // https://developer.apple.com/library/ios/qa/qa1808/_index.html
        let colorDelta: CGFloat = 0.08

        var (red, green, blue, alpha) = colorForType(.LoginButtonBackground).components()

        red = max(0.0, red - colorDelta)
        green = max(0.0, green - colorDelta)
        blue = max(0.0, blue - colorDelta)

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    fileprivate var mappedColors: [String: UIColor]!
}

private extension Theme {
    struct Constants {
        static let VersionValue = 1
        static let VersionKey = "version"
        static let ColorsKey = "colors"
        static let ValuesKey = "values"
    }

    func checkVersion(_ dictionary: [Yaml: Yaml]) throws {
        guard let version = dictionary[Yaml.string(Constants.VersionKey)]?.int else {
            throw ErrorTheme.cannotParseFile(String(localized:"theme_error_cannot_open"))
        }

        guard version == Constants.VersionValue else {
            throw ErrorTheme.wrongVersion(String(localized: "theme_error_cannot_open"))
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
                throw ErrorTheme.cannotParseFile(String(localized: "theme_error_cannot_open", value))
            }

            mappedColors[key] = color
        }

        return mappedColors
    }

    func parseDictionary<T>(_ dictionary: [Yaml: Yaml], forKey key: String, modifyValue: (String) -> T?) throws -> [String: T] {
        guard let yamlDict = dictionary[Yaml.string(key)]?.dictionary else {
            throw ErrorTheme.cannotParseFile(String(localized: "theme_error_cannot_open", key))
        }

        var resultDict = [String: T]()

        for (keyYaml, valueYaml) in yamlDict {
            guard let key = keyYaml.string,
                  let originalValue = valueYaml.string,
                  let valueToSet = modifyValue(originalValue) else {
                throw ErrorTheme.cannotParseFile(String(localized: "theme_error_cannot_open", keyYaml.description, valueYaml.description))
            }

            resultDict[key] = valueToSet
        }

        return resultDict
    }

    func validateMappedColors(_ dictionary: [String: UIColor]) throws {
        for type in ColorType.allValues {
            guard let _ = dictionary[type.rawValue] else {
                throw ErrorTheme.cannotParseFile(String(localized: "theme_error_cannot_open", type.rawValue))
            }
        }
    }
}

