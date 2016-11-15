// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class OCTSubmanagerBootstrapMock: NSObject, OCTSubmanagerBootstrap {
    func addNode(withHost host: String!, port: OCTToxPort, publicKey: String!) {
        // nop
    }
    
    func addPredefinedNodes() {
        // nop
    }
    
    func bootstrap() {
        // nop
    }
    
    func addTCPRelay(withHost host: String!, port: OCTToxPort, publicKey: String!) throws {
        // nop
    }
}
