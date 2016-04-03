//
//  ChatIncomingFileCellSnapshotTest.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02.04.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation
import MobileCoreServices

class ChatIncomingFileCellSnapshotTest: CellSnapshotTest {
    override func setUp() {
        super.setUp()

        recordMode = false
    }

    func testWaitingState() {
        let model = ChatIncomingFileCellModel()
        model.state = .WaitingConfirmation
        model.fileName = "file.txt"
        model.fileSize = "3.14 KB"
        model.fileUTI = kUTTypePlainText as String

        let cell = ChatIncomingFileCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        FBSnapshotVerifyView(cell)
    }

    func testLoading() {
        let model = ChatIncomingFileCellModel()
        model.state = .Loading
        model.fileName = "file.txt"
        model.fileSize = "3.14 KB"
        model.fileUTI = kUTTypePlainText as String

        let progressObject = MockedChatProgressProtocol()

        let cell = ChatIncomingFileCell()
        cell.setupWithTheme(theme, model: model)
        cell.progressObject = progressObject

        progressObject.updateProgress?(progress: 0.43)

        updateCellLayout(cell)
        FBSnapshotVerifyView(cell)
    }

    func testPaused() {
        let model = ChatIncomingFileCellModel()
        model.state = .Paused
        model.fileName = "file.txt"
        model.fileSize = "3.14 KB"
        model.fileUTI = kUTTypePlainText as String

        let progressObject = MockedChatProgressProtocol()

        let cell = ChatIncomingFileCell()
        cell.setupWithTheme(theme, model: model)
        cell.progressObject = progressObject

        progressObject.updateProgress?(progress: 0.43)

        updateCellLayout(cell)
        FBSnapshotVerifyView(cell)
    }

    func testCancelled() {
        let model = ChatIncomingFileCellModel()
        model.state = .Cancelled
        model.fileName = "file.txt"
        model.fileSize = "3.14 KB"
        model.fileUTI = kUTTypePlainText as String

        let cell = ChatIncomingFileCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        FBSnapshotVerifyView(cell)
    }

    func testDone() {
        let model = ChatIncomingFileCellModel()
        model.state = .Done
        model.fileName = "file.txt"
        model.fileSize = "3.14 KB"
        model.fileUTI = kUTTypePlainText as String

        let cell = ChatIncomingFileCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        FBSnapshotVerifyView(cell)
    }

    func testDoneWithImage() {
        let model = ChatIncomingFileCellModel()
        model.state = .Done
        model.fileName = "icon.png"
        model.fileSize = "3.14 KB"
        model.fileUTI = kUTTypePNG as String

        let cell = ChatIncomingFileCell()
        cell.setupWithTheme(theme, model: model)
        cell.setButtonImage(image)

        updateCellLayout(cell)
        FBSnapshotVerifyView(cell)
    }
}
