// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

class KeychainManagerTests: XCTestCase {
    func testToxPassword() {
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

    func testFailedPinAttemptsNumber() {
        let manager = KeychainManager()

        manager.failedPinAttemptsNumber = nil
        XCTAssertNil(manager.failedPinAttemptsNumber)

        manager.failedPinAttemptsNumber = 5
        XCTAssertEqual(manager.failedPinAttemptsNumber!, 5)

        manager.failedPinAttemptsNumber = 8
        XCTAssertEqual(manager.failedPinAttemptsNumber!, 8)

        manager.failedPinAttemptsNumber = nil
        XCTAssertNil(manager.failedPinAttemptsNumber)

        manager.failedPinAttemptsNumber = 3
        XCTAssertEqual(manager.failedPinAttemptsNumber!, 3)

        manager.deleteActiveAccountData()
        XCTAssertNil(manager.failedPinAttemptsNumber)
    }
}

