// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

struct ToxFactory {
    static func createToxWithConfiguration(configuration: OCTManagerConfiguration,
                                    encryptPassword: String,
                                    successBlock: OCTManager -> Void,
                                    failureBlock: NSError -> Void) {
        if NSProcessInfo.processInfo().arguments.contains("UI_TESTING") {
            successBlock(OCTManagerMock())
            return
        }

        OCTManagerFactory.managerWithConfiguration(configuration,
                                                encryptPassword: encryptPassword,
                                                successBlock: successBlock,
                                                failureBlock: failureBlock)
    }
}
