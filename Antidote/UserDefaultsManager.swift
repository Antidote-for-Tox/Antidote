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
            return boolForKey(Keys.isUserLoggedIn)
        }
        set {
            setBool(newValue, forKey: Keys.isUserLoggedIn)
        }
    }

    var IPv6Enabled: Bool {
        get {
            return boolForKey(Keys.IPv6Enabled)
        }
        set {
            setBool(newValue, forKey: Keys.IPv6Enabled)
        }
    }

    var UDPEnabled: Bool {
        get {
            return boolForKey(Keys.UDPEnabled)
        }
        set {
            setBool(newValue, forKey: Keys.UDPEnabled)
        }
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

    func boolForKey(key: String) -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.boolForKey(key)
    }
}
