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
}

class ProfileSettings: NSObject, NSCoding {
    var unlockPinCode: String?

    required override init() {
        unlockPinCode = nil

        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        unlockPinCode = aDecoder.decodeObjectForKey(Constants.UnlockPinCodeKey) as? String

        super.init()
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(unlockPinCode, forKey: Constants.UnlockPinCodeKey)
    }
}
