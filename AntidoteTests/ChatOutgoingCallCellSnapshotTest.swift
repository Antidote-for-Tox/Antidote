// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class ChatOutgoingCallCellSnapshotTest: CellSnapshotTest {
    override func setUp() {
        super.setUp()

        recordMode = false
    }

    func testAnsweredCall() {
        let model = ChatOutgoingCallCellModel()
        model.callDuration = 137
        model.answered = true

        let cell = ChatOutgoingCallCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        verifyView(cell)
    }

    func testNonAnsweredCall() {
        let model = ChatOutgoingCallCellModel()
        model.callDuration = 137
        model.answered = false

        let cell = ChatOutgoingCallCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        verifyView(cell)
    }
}
