//
//  ChatListCellSnapshotTest.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02.04.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

class ChatListCellSnapshotTest: CellSnapshotTest {
    override func setUp() {
        super.setUp()

        recordMode = false
    }

    func testDefault() {
        let model = ChatListCellModel()
        model.avatar = image
        model.nickname = "dvor"
        model.message = "Hi! This is some random message."
        model.dateText = "Yesterday"
        model.status = .Offline
        model.isUnread = false

        let cell = ChatListCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        FBSnapshotVerifyView(cell)
    }

    func testLongMessage() {
        let model = ChatListCellModel()
        model.avatar = image
        model.nickname = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        model.message = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. "
        model.dateText = "Yesterday"
        model.status = .Online
        model.isUnread = false

        let cell = ChatListCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        FBSnapshotVerifyView(cell)
    }

    func testUnread() {
        let model = ChatListCellModel()
        model.avatar = image
        model.nickname = "dvor"
        model.message = "Hi! This is some random message."
        model.dateText = "10:37"
        model.status = .Away
        model.isUnread = true

        let cell = ChatListCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        FBSnapshotVerifyView(cell)
    }
}
