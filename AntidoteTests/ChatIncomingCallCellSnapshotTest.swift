// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class ChatIncomingCallCellSnapshotTest: CellSnapshotTest {
    override func setUp() {
        super.setUp()

        recordMode = false
    }

    func testAnsweredCall() {
        let model = ChatIncomingCallCellModel()
        model.callDuration = 137
        model.answered = true

        let cell = ChatIncomingCallCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        verifyView(cell)
    }

    func testNonAnsweredCall() {
        let model = ChatIncomingCallCellModel()
        model.callDuration = 137
        model.answered = false

        let cell = ChatIncomingCallCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        verifyView(cell)
    }
}
