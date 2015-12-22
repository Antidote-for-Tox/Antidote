//
//  UserStatus.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 20/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

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
}
