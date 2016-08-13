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
        manager.touchIDEnabledActiveAccount = nil
        manager.autoLoginForActiveAccount = nil

        XCTAssertNil(manager.toxPasswordForActiveAccount)
        XCTAssertNil(manager.touchIDEnabledActiveAccount)
        XCTAssertNil(manager.autoLoginForActiveAccount)

        manager.toxPasswordForActiveAccount = "password"
        manager.touchIDEnabledActiveAccount = true
        manager.autoLoginForActiveAccount = true

        XCTAssertEqual(manager.toxPasswordForActiveAccount!, "password")
        XCTAssertTrue(manager.touchIDEnabledActiveAccount!)
        XCTAssertTrue(manager.autoLoginForActiveAccount!)

        manager.toxPasswordForActiveAccount = "another"
        manager.touchIDEnabledActiveAccount = false
        manager.autoLoginForActiveAccount = false

        XCTAssertEqual(manager.toxPasswordForActiveAccount!, "another")
        XCTAssertFalse(manager.touchIDEnabledActiveAccount!)
        XCTAssertFalse(manager.autoLoginForActiveAccount!)

        manager.toxPasswordForActiveAccount = nil
        manager.touchIDEnabledActiveAccount = nil
        manager.autoLoginForActiveAccount = nil

        XCTAssertNil(manager.toxPasswordForActiveAccount)
        XCTAssertNil(manager.touchIDEnabledActiveAccount)
        XCTAssertNil(manager.autoLoginForActiveAccount)

        manager.toxPasswordForActiveAccount = "some pass"
        manager.touchIDEnabledActiveAccount = true
        manager.autoLoginForActiveAccount = false

        XCTAssertEqual(manager.toxPasswordForActiveAccount!, "some pass")
        XCTAssertTrue(manager.touchIDEnabledActiveAccount!)
        XCTAssertFalse(manager.autoLoginForActiveAccount!)

        manager.deleteActiveAccountData()

        XCTAssertNil(manager.toxPasswordForActiveAccount)
        XCTAssertNil(manager.touchIDEnabledActiveAccount)
        XCTAssertNil(manager.autoLoginForActiveAccount)
    }
}

