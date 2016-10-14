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

    var unlockPinCode: String?
    var useTouchID: Bool
    var lockTimeout: LockTimeout

    required override init() {
        unlockPinCode = nil
        useTouchID = false
        lockTimeout = .Immediately

        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        unlockPinCode = aDecoder.decodeObjectForKey(Constants.UnlockPinCodeKey) as? String
        useTouchID = aDecoder.decodeBoolForKey(Constants.UseTouchIDKey)

        if let rawTimeout = aDecoder.decodeObjectForKey(Constants.LockTimeoutKey) as? String {
            lockTimeout = LockTimeout(rawValue: rawTimeout) ?? .Immediately
        }
        else {
            lockTimeout = .Immediately
        }

        super.init()
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(unlockPinCode, forKey: Constants.UnlockPinCodeKey)
        aCoder.encodeBool(useTouchID, forKey: Constants.UseTouchIDKey)
        aCoder.encodeObject(lockTimeout.rawValue, forKey: Constants.LockTimeoutKey)
    }
}
