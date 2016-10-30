// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
    
class OCTSubmanagerFilesMock: NSObject, OCTSubmanagerFiles {
    func sendData(data: NSData, withFileName fileName: String, toChat chat: OCTChat, failureBlock: ((NSError) -> Void)?) {
        // nop
    }
    
    func sendFileAtPath(filePath: String, moveToUploads: Bool, toChat chat: OCTChat, failureBlock: ((NSError) -> Void)?) {
        // nop
    }
    
    func acceptFileTransfer(message: OCTMessageAbstract, failureBlock: ((NSError) -> Void)?) {
        // nop
    }
    
    func cancelFileTransfer(message: OCTMessageAbstract) throws {
        // nop
    }
    
    func retrySendingFile(message: OCTMessageAbstract, failureBlock: ((NSError) -> Void)?) {
        // nop
    }
    
    func pauseFileTransfer(pause: Bool, message: OCTMessageAbstract) throws {
        // nop
    }
    
    func addProgressSubscriber(subscriber: OCTSubmanagerFilesProgressSubscriber, forFileTransfer message: OCTMessageAbstract) throws {
        // nop
    }
    
    func removeProgressSubscriber(subscriber: OCTSubmanagerFilesProgressSubscriber, forFileTransfer message: OCTMessageAbstract) throws {
        // nop
    }
}
