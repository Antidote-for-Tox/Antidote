//
//  UserDefaultsManager.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 10/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

class UserDefaultsManager {
    var lastActiveProfile: String? {
        get {
            return stringForKey(Keys.LastActiveProfile)
        }
        set {
            setObject(newValue, forKey: Keys.LastActiveProfile)
        }
    }

    var UDPEnabled: Bool {
        get {
            return boolForKey(Keys.UDPEnabled, defaultValue: true)
        }
        set {
            setBool(newValue, forKey: Keys.UDPEnabled)
        }
    }

    var showNotificationPreview: Bool {
        get {
            return boolForKey(Keys.ShowNotificationsPreview, defaultValue: true)
        }
        set {
            setBool(newValue, forKey: Keys.ShowNotificationsPreview)
        }
    }

    enum AutodownloadImages: String {
        case Never
        case UsingWiFi
        case Always
    }

    var autodownloadImages: AutodownloadImages {
        get {
            let defaultValue = AutodownloadImages.Never

            guard let string = stringForKey(Keys.AutodownloadImages) else {
                return defaultValue
            }
            return AutodownloadImages(rawValue: string) ?? defaultValue
        }
        set {
            setObject(newValue.rawValue, forKey: Keys.AutodownloadImages)
        }
    }

    func resetUDPEnabled() {
        removeObjectForKey(Keys.UDPEnabled)
    }
}

private extension UserDefaultsManager {
    struct Keys {
        static let LastActiveProfile = "user-info/last-active-profile"
        static let UDPEnabled = "user-info/udp-enabled"
        static let ShowNotificationsPreview = "user-info/snow-notification-preview"
        static let AutodownloadImages = "user-info/autodownload-images"
    }

    func setObject(object: AnyObject?, forKey key: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(object, forKey:key)
        defaults.synchronize()
    }

    func stringForKey(key: String) -> String? {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.stringForKey(key)
    }

    func setBool(value: Bool, forKey key: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(value, forKey: key)
        defaults.synchronize()
    }

    func boolForKey(key: String, defaultValue: Bool) -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()

        if let result = defaults.objectForKey(key) {
            return result.boolValue
        }
        else {
            return defaultValue
        }
    }

    func removeObjectForKey(key: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(key)
        defaults.synchronize()
    }
}
