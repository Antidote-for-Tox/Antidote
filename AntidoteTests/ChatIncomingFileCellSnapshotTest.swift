// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import MobileCoreServices

class ChatIncomingFileCellSnapshotTest: CellSnapshotTest {
    override func setUp() {
        super.setUp()

        recordMode = false
    }

    func testWaitingState() {
        let model = ChatIncomingFileCellModel()
        model.state = .waitingConfirmation
        model.fileName = "file.txt"
        model.fileSize = "3.14 KB"
        model.fileUTI = kUTTypePlainText as String

        let cell = ChatIncomingFileCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        verifyView(cell)
    }

    func testLoading() {
        let model = ChatIncomingFileCellModel()
        model.state = .loading
        model.fileName = "file.txt"
        model.fileSize = "3.14 KB"
        model.fileUTI = kUTTypePlainText as String

        let progressObject = MockedChatProgressProtocol()

        let cell = ChatIncomingFileCell()
        cell.setupWithTheme(theme, model: model)
        cell.progressObject = progressObject

        progressObject.updateProgress?(0.43)

        updateCellLayout(cell)
        verifyView(cell)
    }

    func testPaused() {
        let model = ChatIncomingFileCellModel()
        model.state = .paused
        model.fileName = "file.txt"
        model.fileSize = "3.14 KB"
        model.fileUTI = kUTTypePlainText as String

        let progressObject = MockedChatProgressProtocol()

        let cell = ChatIncomingFileCell()
        cell.setupWithTheme(theme, model: model)
        cell.progressObject = progressObject

        progressObject.updateProgress?(0.43)

        updateCellLayout(cell)
        verifyView(cell)
    }

    func testCancelled() {
        let model = ChatIncomingFileCellModel()
        model.state = .cancelled
        model.fileName = "file.txt"
        model.fileSize = "3.14 KB"
        model.fileUTI = kUTTypePlainText as String

        let cell = ChatIncomingFileCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        verifyView(cell)
    }

    func testDone() {
        let model = ChatIncomingFileCellModel()
        model.state = .done
        model.fileName = "file.txt"
        model.fileSize = "3.14 KB"
        model.fileUTI = kUTTypePlainText as String

        let cell = ChatIncomingFileCell()
        cell.setupWithTheme(theme, model: model)

        updateCellLayout(cell)
        verifyView(cell)
    }

    func testDoneWithImage() {
        let model = ChatIncomingFileCellModel()
        model.state = .done
        model.fileName = "icon.png"
        model.fileSize = "3.14 KB"
        model.fileUTI = kUTTypePNG as String

        let cell = ChatIncomingFileCell()
        cell.setupWithTheme(theme, model: model)
        cell.setButtonImage(image)

        updateCellLayout(cell)
        verifyView(cell)
    }
}
