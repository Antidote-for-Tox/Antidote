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
            return stringForKey(Keys.lastActiveProfile)
        }
        set {
            setObject(newValue, forKey: Keys.lastActiveProfile)
        }
    }

    var isUserLoggedIn: Bool {
        get {
            return boolForKey(Keys.isUserLoggedIn, defaultValue: false)
        }
        set {
            setBool(newValue, forKey: Keys.isUserLoggedIn)
        }
    }

    var IPv6Enabled: Bool {
        get {
            return boolForKey(Keys.IPv6Enabled, defaultValue: true)
        }
        set {
            setBool(newValue, forKey: Keys.IPv6Enabled)
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

    func resetIPv6Enabled() {
        removeObjectForKey(Keys.IPv6Enabled)
    }

    func resetUDPEnabled() {
        removeObjectForKey(Keys.UDPEnabled)
    }
}

private extension UserDefaultsManager {
    struct Keys {
        static let lastActiveProfile = "user-info/last-active-profile"
        static let isUserLoggedIn = "user-info/is-user-logged-in"
        static let IPv6Enabled = "user-info/ipv6-enabled"
        static let UDPEnabled = "user-info/udp-enabled"
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
        NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
    }
}
