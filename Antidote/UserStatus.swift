// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

enum UserStatus {
    case offline
    case online
    case away
    case busy

    init(connectionStatus: OCTToxConnectionStatus, userStatus: OCTToxUserStatus) {
        switch (connectionStatus, userStatus) {
            case (.none, _):
                self = .offline
            case (_, .none):
                self = .online
            case (_, .away):
                self = .away
            case (_, .busy):
                self = .busy
        }
    }

    func toString() -> String {
        switch self {
            case .offline:
                return String(localized: "status_offline")
            case .online:
                return String(localized: "status_online")
            case .away:
                return String(localized: "status_away")
            case .busy:
                return String(localized: "status_busy")
        }
    }
}
