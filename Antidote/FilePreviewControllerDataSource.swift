//
//  FilePreviewControllerDataSource.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 23.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation
import QuickLook

private class FilePreviewItem: NSObject, QLPreviewItem {
    @objc var previewItemURL: NSURL
    @objc var previewItemTitle: String?

    init(url: NSURL, title: String?) {
        self.previewItemURL = url
            self.previewItemTitle = title
    }
}

class FilePreviewControllerDataSource: NSObject , QuickLookPreviewControllerDataSource {
    weak var previewController: QuickLookPreviewController?

    let messages: RLMResults
    var messagesToken: RLMNotificationToken?

    init(chat: OCTChat, submanagerObjects: OCTSubmanagerObjects) {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "chat.uniqueIdentifier == %@ AND messageFile != nil", chat.uniqueIdentifier),

            NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "messageFile.fileType == \(OCTMessageFileType.Ready.rawValue)"),
                NSPredicate(format: "sender == nil AND messageFile.fileType == \(OCTMessageFileType.Canceled.rawValue)"),
            ]),
        ])

        self.messages = submanagerObjects.objectsForType(.MessageAbstract, predicate: predicate).sortedResultsUsingProperty("dateInterval", ascending: true)

        super.init()

        messagesToken = messages.addNotificationBlock { [unowned self] _, changes, error in
            if let error = error {
                fatalError("\(error)")
            }

            self.previewController?.reloadData()
        }
    }

    deinit {
        messagesToken?.stop()
    }

    func indexOfMessage(message: OCTMessageAbstract) -> Int? {
        return Int(messages.indexOfObject(message))
    }
}

extension FilePreviewControllerDataSource: QLPreviewControllerDataSource {
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return Int(messages.count)
    }

    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        let message = messages[UInt(index)] as! OCTMessageAbstract

        let url = NSURL.fileURLWithPath(message.messageFile!.filePath()!)

        return FilePreviewItem(url: url, title: message.messageFile!.fileName)
    }
}
