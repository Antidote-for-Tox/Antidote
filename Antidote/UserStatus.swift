// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

enum UserStatus {
    case Offline
    case Online
    case Away
    case Busy

    init(connectionStatus: OCTToxConnectionStatus, userStatus: OCTToxUserStatus) {
        switch (connectionStatus, userStatus) {
            case (.None, _):
                self = .Offline
            case (_, .None):
                self = .Online
            case (_, .Away):
                self = .Away
            case (_, .Busy):
                self = .Busy
        }
    }

    func toString() -> String {
        switch self {
            case .Offline:
                return String(localized: "status_offline")
            case .Online:
                return String(localized: "status_online")
            case .Away:
                return String(localized: "status_away")
            case .Busy:
                return String(localized: "status_busy")
        }
    }
}
