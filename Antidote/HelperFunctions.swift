// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

func isAddressString(string: String) -> Bool {
    let nsstring = string as NSString

    if nsstring.length != Int(kOCTToxAddressLength) {
        return false
    }

    let validChars = NSCharacterSet(charactersInString: "1234567890abcdefABCDEF")
    let components = nsstring.componentsSeparatedByCharactersInSet(validChars)
    let leftChars = components.joinWithSeparator("")

    return leftChars.isEmpty
}
