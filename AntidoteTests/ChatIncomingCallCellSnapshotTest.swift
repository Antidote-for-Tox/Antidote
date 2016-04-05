//
//  ChatIncomingCallCellSnapshotTest.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02.04.16.
//  Copyright © 2016 dvor. All rights reserved.
//

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
