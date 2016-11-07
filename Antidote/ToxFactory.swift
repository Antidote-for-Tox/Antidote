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
