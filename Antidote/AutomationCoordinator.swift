// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import MobileCoreServices

private struct Constants {
    static let MaxFileSizeWiFi: OCTToxFileSize = 20 * 1024 * 1024
    static let MaxFileSizeWWAN: OCTToxFileSize = 5 * 1024 * 1024
}

class AutomationCoordinator: NSObject {
    fileprivate weak var submanagerFiles: OCTSubmanagerFiles!

    fileprivate var fileMessagesToken: RLMNotificationToken?
    fileprivate let userDefaults = UserDefaultsManager()
    fileprivate let reachability = Reach()

    init(submanagerObjects: OCTSubmanagerObjects, submanagerFiles: OCTSubmanagerFiles) {
        self.submanagerFiles = submanagerFiles

        super.init()

        let predicate = NSPredicate(format: "senderUniqueIdentifier != nil AND messageFile != nil")
        let results = submanagerObjects.messages(predicate: predicate)
        fileMessagesToken = results.addNotificationBlock { [unowned self] change in
            switch change {
                case .initial:
                    break
                case .update(let results, _, let insertions, _):
                    guard let results = results else {
                        break
                    }

                    for index in insertions {
                        let message = results[index]
                        self.proceedNewFileMessage(message)
                    }
                case .error(let error):
                    fatalError("\(error)")
            }
        }
    }
}

extension AutomationCoordinator: CoordinatorProtocol {
    func startWithOptions(_ options: CoordinatorOptions?) {
        // nop
    }
}

private extension AutomationCoordinator {
    func proceedNewFileMessage(_ message: OCTMessageAbstract) {
        let usingWiFi = self.usingWiFi()
        switch userDefaults.autodownloadImages {
            case .Never:
                return
            case .UsingWiFi:
                if !usingWiFi {
                    return
                }
            case .Always:
                break
        }

        if !UTTypeConformsTo(message.messageFile!.fileUTI as CFString? ?? "" as CFString, kUTTypeImage) {
            // download images only
            return
        }

        // skip too large images
        if usingWiFi {
            if message.messageFile!.fileSize > Constants.MaxFileSizeWiFi {
                return
            }
        }
        else {
            if message.messageFile!.fileSize > Constants.MaxFileSizeWWAN {
                return
            }
        }

        // workaround for deadlock in objcTox https://github.com/Antidote-for-Tox/objcTox/issues/51
        let delayTime = DispatchTime.now() + Double(Int64(0.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
            self?.submanagerFiles.acceptFileTransfer(message, failureBlock: nil)
        }
    }

    func usingWiFi() -> Bool
    {
        switch reachability.connectionStatus() {
            case .offline:
                return false
            case .unknown:
                return false
            case .online(let type):
                switch type {
                    case .wwan:
                        return false
                    case .wiFi:
                        return true
                }
        }
    }
}
