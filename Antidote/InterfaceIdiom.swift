// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

enum InterfaceIdiom {
    case iPhone
    case iPad

    static func current() -> InterfaceIdiom {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            return .iPad
        }
        else {
            // assume that we are on iPhone
            return .iPhone
        }
    }
}

