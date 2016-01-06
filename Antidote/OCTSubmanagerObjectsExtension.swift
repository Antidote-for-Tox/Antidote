//
//  OCTSubmanagerObjectsExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 14/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import Foundation

extension OCTSubmanagerObjects {
    func fetchedResultsControllerForType(
            type: OCTFetchRequestType,
            predicate: NSPredicate? = nil,
            sortDescriptors: [RLMSortDescriptor]? = nil,
            sectionNameKeyPath: String? = nil,
            delegate: RBQFetchedResultsControllerDelegate? = nil) -> RBQFetchedResultsController {

        let request = fetchRequestForType(type, withPredicate: predicate)
        request.sortDescriptors = sortDescriptors

        let controller = RBQFetchedResultsController(
                fetchRequest: request,
                sectionNameKeyPath: sectionNameKeyPath,
                cacheName: nil)

        controller.delegate = delegate

        return controller
    }
}
