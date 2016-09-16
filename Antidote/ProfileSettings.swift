//
//  ProfileSettings.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 16/09/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

private struct Constants {
    static let UnlockPinCodeKey = "UnlockPinCodeKey"
    static let UseTouchID = "UseTouchID"
}

class ProfileSettings: NSObject, NSCoding {
    var unlockPinCode: String?
    var useTouchID: Bool

    required override init() {
        unlockPinCode = nil
        useTouchID = false

        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        unlockPinCode = aDecoder.decodeObjectForKey(Constants.UnlockPinCodeKey) as? String
        useTouchID = aDecoder.decodeBoolForKey(Constants.UseTouchID)

        super.init()
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(unlockPinCode, forKey: Constants.UnlockPinCodeKey)
        aCoder.encodeBool(useTouchID, forKey: Constants.UseTouchID)
    }
}
