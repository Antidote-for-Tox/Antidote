// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
    
class OCTSubmanagerFilesMock: NSObject, OCTSubmanagerFiles {
    func send(_ data: Data, withFileName fileName: String, to chat: OCTChat, failureBlock: ((Error) -> Void)? = nil) {
        // nop
    }
    
    func sendFile(atPath filePath: String, moveToUploads: Bool, to chat: OCTChat, failureBlock: ((Error) -> Void)? = nil) {
        // nop
    }
    
    func acceptFileTransfer(_ message: OCTMessageAbstract, failureBlock: ((Error) -> Void)? = nil) {
        // nop
    }
    
    func cancelFileTransfer(_ message: OCTMessageAbstract) throws {
        // nop
    }
    
    func retrySendingFile(_ message: OCTMessageAbstract, failureBlock: ((Error) -> Void)? = nil) {
        // nop
    }
    
    func pauseFileTransfer(_ pause: Bool, message: OCTMessageAbstract) throws {
        // nop
    }
    
    func add(_ subscriber: OCTSubmanagerFilesProgressSubscriber, forFileTransfer message: OCTMessageAbstract) throws {
        // nop
    }
    
    func remove(_ subscriber: OCTSubmanagerFilesProgressSubscriber, forFileTransfer message: OCTMessageAbstract) throws {
        // nop
    }
}
