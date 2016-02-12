//
//  CoordinatorProtocol.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

typealias CoordinatorOptions = [String: Any]

protocol CoordinatorProtocol {
    /**
        This method will be called when coordinator should start working.

        - Parameters:
          - options: Options to start with. Options are used for recovering state of coordinator on recreation.
     */
    func startWithOptions(options: CoordinatorOptions?)
}
