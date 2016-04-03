//
//  ChatMovableDateCellSnapshotTest.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02.04.16.
//  Copyright © 2016 dvor. All rights reserved.
//

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
        FBSnapshotVerifyView(cell)
    }

    func testPanned() {
        let model = ChatMovableDateCellModel()
        model.dateString = "03:13"

        let cell = ChatMovableDateCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        cell.movableOffset = -200.0
        FBSnapshotVerifyView(cell)
    }
}
