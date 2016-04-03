//
//  ChatOutgoingCallCellSnapshotTest.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02.04.16.
//  Copyright © 2016 dvor. All rights reserved.
//

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
        FBSnapshotVerifyView(cell)
    }

    func testNonAnsweredCall() {
        let model = ChatOutgoingCallCellModel()
        model.callDuration = 137
        model.answered = false

        let cell = ChatOutgoingCallCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        FBSnapshotVerifyView(cell)
    }
}
