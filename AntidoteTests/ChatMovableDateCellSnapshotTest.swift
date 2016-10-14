// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class ChatMovableDateCellSnapshotTest: CellSnapshotTest {
    override func setUp() {
        super.setUp()

        recordMode = false
    }

    func testDefault() {
        let model = ChatMovableDateCellModel()
        model.dateString = "03:13"

        let cell = ChatMovableDateCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        verifyView(cell)
    }

    func testPanned() {
        let model = ChatMovableDateCellModel()
        model.dateString = "03:13"

        let cell = ChatMovableDateCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        cell.movableOffset = -200.0
        verifyView(cell)
    }
}
