// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/**
    Bridge between objcTox subscriber and chat progress protocol.
 */
class ChatProgressBridge: NSObject, ChatProgressProtocol {
    var updateProgress: ((_ progress: Float) -> Void)?
    var updateEta: ((_ eta: CFTimeInterval, _ bytesPerSecond: OCTToxFileSize) -> Void)?
}

extension ChatProgressBridge: OCTSubmanagerFilesProgressSubscriber {
    func submanagerFiles(onProgressUpdate progress: Float, message: OCTMessageAbstract) {
        updateProgress?(progress)
    }

    func submanagerFiles(onEtaUpdate eta: CFTimeInterval, bytesPerSecond: OCTToxFileSize, message: OCTMessageAbstract) {
        updateEta?(eta, bytesPerSecond)
    }
}
