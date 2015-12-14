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
            sectionNameKeyPath: String? = nil,
            delegate: RBQFetchedResultsControllerDelegate? = nil) -> RBQFetchedResultsController {

        let request = fetchRequestForType(type, withPredicate: predicate)
        let controller = RBQFetchedResultsController(
                fetchRequest: request,
                sectionNameKeyPath: sectionNameKeyPath,
                cacheName: nil)

        controller.delegate = delegate
        controller.performFetch()

        return controller
    }
}
