//
//  ToxManagerFactory.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 08/08/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

class ToxManagerFactory {
    /**
        Creates a tox manager.

        - Parameters:
          - password: Password to create tox manager with.
          - confuguration: Configuration to use.
          - successClosure: Closure called on success. Will be called on main queue
          - failureClosure: Closure called on failure. Will be called on main queue. NSError will contain OCTManagerInitError.
     */
    class func managerWithPassword(password: String?,
                                   configuration: OCTManagerConfiguration,
                                   successClosure: (OCTManager -> Void),
                                   failureClosure: (NSError -> Void)?) {
        let databasePassword = databasePasswordFromUserPassword(password)

        OCTManager.managerWithConfiguration(configuration,
                                            toxPassword: password,
                                            databasePassword: databasePassword,
                                            successBlock:successClosure,
                                            failureBlock:failureClosure)
    }
}

private extension ToxManagerFactory {
    class func databasePasswordFromUserPassword(password: String?) -> String {
        return "123"
    }
}
