// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class OCTSubmanagerDNSMock: NSObject, OCTSubmanagerDNS {
    func addTox3Server(_ domain: String, publicKey: String) {
        // nop
    }
    
    func addPredefinedTox3Servers() {
        // nop
    }
    
    func tox3Discovery(for string: String, success successBlock: ((String) -> Void)?, failure failureBlock: ((Error) -> Void)? = nil) {
        // nop
    }
    
    func tox1Discovery(for string: String, success successBlock: ((String) -> Void)?, failure failureBlock: ((Error) -> Void)? = nil) {
        // nop
    }
}
