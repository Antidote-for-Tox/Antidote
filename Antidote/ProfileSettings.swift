// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

private struct Constants {
    static let UnlockPinCodeKey = "UnlockPinCodeKey"
    static let UseTouchIDKey = "UseTouchIDKey"
    static let LockTimeoutKey = "LockTimeoutKey"
}

class ProfileSettings: NSObject, NSCoding {
    enum LockTimeout: String {
        case Immediately
        case Seconds30
        case Minute1
        case Minute2
        case Minute5
    }

    /// Pin code used to unlock device.
    var unlockPinCode: String?

    /// Whether use Touch ID for unlocking Antidote.
    var useTouchID: Bool

    /// Time after which Antidote will be blocked in background.
    var lockTimeout: LockTimeout

    required override init() {
        unlockPinCode = nil
        useTouchID = false
        lockTimeout = .Immediately

        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        unlockPinCode = aDecoder.decodeObject(forKey: Constants.UnlockPinCodeKey) as? String
        useTouchID = aDecoder.decodeBool(forKey: Constants.UseTouchIDKey)

        if let rawTimeout = aDecoder.decodeObject(forKey: Constants.LockTimeoutKey) as? String {
            lockTimeout = LockTimeout(rawValue: rawTimeout) ?? .Immediately
        }
        else {
            lockTimeout = .Immediately
        }

        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(unlockPinCode, forKey: Constants.UnlockPinCodeKey)
        aCoder.encode(useTouchID, forKey: Constants.UseTouchIDKey)
        aCoder.encode(lockTimeout.rawValue, forKey: Constants.LockTimeoutKey)
    }
}
