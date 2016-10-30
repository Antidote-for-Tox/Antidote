// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class OCTSubmanagerDNSMock: NSObject, OCTSubmanagerDNS {
    func addTox3Server(domain: String, publicKey: String) {
        // nop
    }
    
    func addPredefinedTox3Servers() {
        // nop
    }
    
    func tox3DiscoveryForString(string: String, success successBlock: ((String) -> Void)?, failure failureBlock: ((NSError) -> Void)?) {
        // nop
    }
    
    func tox1DiscoveryForString(string: String, success successBlock: ((String) -> Void)?, failure failureBlock: ((NSError) -> Void)?) {
        // nop
    }
}
