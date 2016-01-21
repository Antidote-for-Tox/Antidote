//
//  HelperFunctions.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 25/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

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
