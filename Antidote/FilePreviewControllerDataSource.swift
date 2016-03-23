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

    let messagesController: RBQFetchedResultsController

    init(chat: OCTChat, submanagerObjects: OCTSubmanagerObjects) {
        let predicate = NSPredicate(format: "chat.uniqueIdentifier == %@ AND messageFile != nil AND messageFile.fileType == %d", chat.uniqueIdentifier, OCTMessageFileType.Ready.rawValue)

        self.messagesController = submanagerObjects.fetchedResultsControllerForType(
                .MessageAbstract,
                predicate: predicate,
                sortDescriptors: [RLMSortDescriptor(property: "dateInterval", ascending: true)])

        super.init()

        messagesController.delegate = self
        messagesController.performFetch()
    }

    func indexOfMessage(message: OCTMessageAbstract) -> Int? {
        return messagesController.indexPathForObject(message)?.row
    }
}

extension FilePreviewControllerDataSource: RBQFetchedResultsControllerDelegate {
   func controllerDidChangeContent(controller: RBQFetchedResultsController) {
       previewController?.reloadData()
   }
}

extension FilePreviewControllerDataSource: QLPreviewControllerDataSource {
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return messagesController.numberOfRowsForSectionIndex(0)
    }

    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        let message = messagesController.objectAtIndexPath(indexPath) as! OCTMessageAbstract

        let url = NSURL.fileURLWithPath(message.messageFile!.filePath()!)

        return FilePreviewItem(url: url, title: message.messageFile!.fileName)
    }
}
