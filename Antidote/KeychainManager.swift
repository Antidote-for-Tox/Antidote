// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

private struct Constants {
    static let ActiveAccountDataService = "me.dvor.Antidote.KeychainManager.ActiveAccountDataService"

    static let toxPasswordForActiveAccount = "toxPasswordForActiveAccount"
}

class KeychainManager {
    /// Tox password used to encrypt/decrypt active account.
    var toxPasswordForActiveAccount: String? {
        get {
            return getStringForKey(Constants.toxPasswordForActiveAccount)
        }
        set {
            setString(newValue, forKey: Constants.toxPasswordForActiveAccount)
        }
    }

    /// Removes all data related to active account.
    func deleteActiveAccountData() {
        self.toxPasswordForActiveAccount = nil
    }
}

private extension KeychainManager {
    func getStringForKey(key: String) -> String? {
        guard let data = getDataForKey(key) else {
            return nil
        }

        return NSString(data: data, encoding: NSUTF8StringEncoding) as? String
    }

    func setString(string: String?, forKey key: String) {
        let data = string?.dataUsingEncoding(NSUTF8StringEncoding)
        setData(data, forKey: key)
    }

    func getBoolForKey(key: String) -> Bool? {
        guard let data = getDataForKey(key) else {
            return nil
        }

        return UnsafePointer(data.bytes).memory == 1
    }

    func setBool(value: Bool?, forKey key: String) {
        var data: NSData? = nil

        if let value = value {
            var bytes = value ? 1 : 0
            withUnsafePointer(&bytes) {
                data = NSData(bytes: $0, length: sizeof(Int))
            }
        }

        setData(data, forKey: key)
    }

    func getDataForKey(key: String) -> NSData? {
        var query = genericQueryWithKey(key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue

        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(&queryResult) {
            SecItemCopyMatching(query, UnsafeMutablePointer($0))
        }

        if status == errSecItemNotFound {
            return nil
        }

        guard status == noErr else {
            log("Error when getting keychain data for key \(key), status \(status)")
            return nil
        }

        guard let data = queryResult as? NSData else {
            log("Unexpected data for key \(key)")
            return nil
        }

        return data
    }

    func setData(newData: NSData?, forKey key: String) {
        let oldData = getDataForKey(key)

        switch (oldData, newData) {
            case (.Some(_), .Some(let data)):
                // Update
                let query = genericQueryWithKey(key)

                var attributesToUpdate = [String : AnyObject]()
                attributesToUpdate[kSecValueData as String] = data

                let status = SecItemUpdate(query, attributesToUpdate)
                guard status == noErr else {
                    log("Error when updating keychain data for key \(key), status \(status)")
                    return
                }

            case (.Some(_), .None):
                // Delete
                let query = genericQueryWithKey(key)
                let status = SecItemDelete(query)
                guard status == noErr else {
                    log("Error when updating keychain data for key \(key), status \(status)")
                    return
                }

            case (.None, .Some(let data)):
                // Add
                var query = genericQueryWithKey(key)
                query[kSecValueData as String] = data

                let status = SecItemAdd(query, nil)
                guard status == noErr else {
                    log("Error when setting keychain data for key \(key), status \(status)")
                    return
                }

            case (.None, .None):
                // Nothing to do here, no changes
                break
        }
    }

    func genericQueryWithKey(key: String) -> [String : AnyObject] {
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = Constants.ActiveAccountDataService
        query[kSecAttrAccount as String] = key
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        return query
    }
}
