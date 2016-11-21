// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class ChatGenericFileCellModel: ChatMovableDateCellModel {
    enum State {
        case waitingConfirmation
        case loading
        case paused
        case cancelled
        case done
    }

    var state: State = .waitingConfirmation
    var fileName: String?
    var fileSize: String?
    var fileUTI: String?

    var startLoadingHandle: ((Void) -> Void)?
    var cancelHandle: ((Void) -> Void)?
    var retryHandle: ((Void) -> Void)?
    var pauseOrResumeHandle: ((Void) -> Void)?
    var openHandle: ((Void) -> Void)?
}
