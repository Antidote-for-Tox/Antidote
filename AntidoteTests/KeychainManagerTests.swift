//
//  KeychainManagerTests.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 13/08/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import XCTest

class KeychainManagerTests: XCTestCase {
    func testKeychainManager() {
        let manager = KeychainManager()

        manager.toxPasswordForActiveAccount = nil
        XCTAssertNil(manager.toxPasswordForActiveAccount)

        manager.toxPasswordForActiveAccount = "password"
        XCTAssertEqual(manager.toxPasswordForActiveAccount!, "password")

        manager.toxPasswordForActiveAccount = "another"
        XCTAssertEqual(manager.toxPasswordForActiveAccount!, "another")

        manager.toxPasswordForActiveAccount = nil
        XCTAssertNil(manager.toxPasswordForActiveAccount)

        manager.toxPasswordForActiveAccount = "some pass"
        XCTAssertEqual(manager.toxPasswordForActiveAccount!, "some pass")

        manager.deleteActiveAccountData()
        XCTAssertNil(manager.toxPasswordForActiveAccount)
    }
}

