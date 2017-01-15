// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class ChatOutgoingTextCellSnapshotTest: CellSnapshotTest {
    override func setUp() {
        super.setUp()

        recordMode = false
    }

    func testSmallMessage() {
        let model = ChatOutgoingTextCellModel()
        model.message = "Hi"
        model.delivered = true

        let cell = ChatOutgoingTextCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        verifyView(cell)
    }

    func testMediumMessage() {
        let model = ChatOutgoingTextCellModel()
        model.message = "Some nice medium message"
        model.delivered = true

        let cell = ChatOutgoingTextCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        verifyView(cell)
    }

    func testMediumMessageUndelivered() {
        let model = ChatOutgoingTextCellModel()
        model.message = "Some nice medium message"
        model.delivered = false

        let cell = ChatOutgoingTextCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        verifyView(cell)
    }

    func testHugeMessage() {
        let model = ChatOutgoingTextCellModel()
        model.message = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. "
        model.delivered = true

        let cell = ChatOutgoingTextCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        verifyView(cell)
    }

    // Broken on Travic CI.
    // func testWithLink() {
    //     let model = ChatOutgoingTextCellModel()
    //     model.message = "Lorem ipsum dolor sit amet, https://tox.chat consectetur adipiscing elit, +1234567890"
    //     model.delivered = true

    //     let cell = ChatOutgoingTextCell()
    //     cell.setupWithTheme(theme, model: model)

    //     updateCellLayout(cell)

    //     let expectation = self.expectation(description: "link rendering expectation")

    //     let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    //     DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
    //         self?.verifyView(cell)
    //         expectation.fulfill()
    //     }

    //     waitForExpectations(timeout: 1.0, handler: nil)
    // }
}
