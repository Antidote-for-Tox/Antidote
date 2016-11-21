// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

struct ToxFactory {
    static func createToxWithConfiguration(_ configuration: OCTManagerConfiguration,
                                    encryptPassword: String,
                                    successBlock: @escaping (OCTManager) -> Void,
                                    failureBlock: @escaping (Error) -> Void) {
        if ProcessInfo.processInfo.arguments.contains("UI_TESTING") {
            successBlock(OCTManagerMock())
            return
        }

        OCTManagerFactory.manager(with: configuration,
                                                encryptPassword: encryptPassword,
                                                successBlock: successBlock,
                                                failureBlock: failureBlock)
    }
}
