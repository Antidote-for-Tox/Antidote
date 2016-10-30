//
//  ToxFactory.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 29/10/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

struct ToxFactory {
    static func createToxWithConfiguration(configuration: OCTManagerConfiguration,
                                    encryptPassword: String,
                                    successBlock: OCTManager -> Void,
                                    failureBlock: NSError -> Void) {
        #if SCREENSHOTS_MOCK
        successBlock(OCTManagerMock())
        #else

        OCTManagerFactory.managerWithConfiguration(configuration,
                                                encryptPassword: encryptPassword,
                                                successBlock: successBlock,
                                                failureBlock: failureBlock)
        #endif
    }
}
