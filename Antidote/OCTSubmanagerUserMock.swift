// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
    
class OCTSubmanagerUserMock: NSObject, OCTSubmanagerUser {
    weak var delegate: OCTSubmanagerUserDelegate? = nil
    var connectionStatus: OCTToxConnectionStatus = .TCP
    var userAddress: String = "123"
    var publicKey: String = "123"
    var nospam: OCTToxNoSpam = 123
    var userStatus: OCTToxUserStatus = .None

    override init() {
        super.init()

        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            self?.delegate?.submanagerUser(self!, connectionStatusUpdate: self!.connectionStatus)
        }
    }
    
    func setUserName(name: String?) throws {
        // nop
    }
    
    func userName() -> String? {
        return nil
    }
    
    func setUserStatusMessage(statusMessage: String?) throws {
        // nop
    }
    
    func userStatusMessage() -> String? {
        return nil
    }
    
    func setUserAvatar(avatar: NSData?) throws {
        // nop
    }
    
    func userAvatar() -> NSData? {
        return nil
    }
}
