//
//  ChatProgressBridge.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 22.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

/**
    Bridge between objcTox subscriber and chat progress protocol.
 */
class ChatProgressBridge: NSObject, ChatProgressProtocol {
    var updateProgress: ((progress: Float) -> Void)?
    var updateEta: ((eta: CFTimeInterval, bytesPerSecond: OCTToxFileSize) -> Void)?
}

extension ChatProgressBridge: OCTSubmanagerFilesProgressSubscriber {
    func submanagerFilesOnProgressUpdate(progress: Float, message: OCTMessageAbstract) {
        updateProgress?(progress: progress)
    }

    func submanagerFilesOnEtaUpdate(eta: CFTimeInterval, bytesPerSecond: OCTToxFileSize, message: OCTMessageAbstract) {
        updateEta?(eta: eta, bytesPerSecond: bytesPerSecond)
    }
}
