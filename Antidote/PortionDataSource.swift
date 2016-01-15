//
//  PortionDataSource.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 15/01/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

protocol PortionDataSourceDelegate: class {
    func portionDataSourceBeginUpdates()
    func portionDataSourceEndUpdates()

    func portionDataSourceInsertObjectAtIndexPath(indexPath: NSIndexPath)
    func portionDataSourceDeleteObjectAtIndexPath(indexPath: NSIndexPath)
    func portionDataSourceReloadObjectAtIndexPath(indexPath: NSIndexPath)
    func portionDataSourceMoveObjectAtIndexPath(indexPath: NSIndexPath, toIndexPath: NSIndexPath)
}

/**
    PortionDataSource is a wrapper on RBQFetchedResultsController which provides only some amount of data (portion).

    It would be nice to have generic class PortionDataSource<ObjectType> instead of using AnyObject.
    However this is not currently possible. See https://gist.github.com/josephlord/5089019943b3667e5516
 */
class PortionDataSource: NSObject {
    weak var delegate: PortionDataSourceDelegate?

    private let controller: RBQFetchedResultsController
    private let portionSize: Int
    private var currentLimit: Int = 0

    init(controller: RBQFetchedResultsController, portionSize: Int) {
        self.controller = controller
        self.portionSize = portionSize

        super.init()

        controller.delegate = self
        controller.performFetch()

        increaseLimit()
    }

    func numberOfObjects() -> Int {
        return min(currentLimit, controller.numberOfRowsForSectionIndex(0))
    }

    func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        let indexPath = toInnerIndexPath(indexPath)

        return controller.objectAtIndexPath(indexPath) as! AnyObject
    }

    /**
        Increases available data by portion size.
     */
    func increaseLimit() -> Bool {
        let previous = currentLimit

        currentLimit = currentLimit + portionSize

        if currentLimit > controller.numberOfRowsForSectionIndex(0) {
            currentLimit = controller.numberOfRowsForSectionIndex(0)
        }

        return currentLimit != previous
    }

    func reset() {
        controller.reset()
    }
}

extension PortionDataSource: RBQFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: RBQFetchedResultsController) {
        delegate?.portionDataSourceBeginUpdates()
    }

   func controllerDidChangeContent(controller: RBQFetchedResultsController) {
       delegate?.portionDataSourceEndUpdates()
   }

    func controller(
            controller: RBQFetchedResultsController,
            didChangeObject anObject: RBQSafeRealmObject,
            atIndexPath indexPath: NSIndexPath?,
            forChangeType type: RBQFetchedResultsChangeType,
            newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                let outer = toOuterIndexPath(newIndexPath!)
                currentLimit++
                delegate?.portionDataSourceInsertObjectAtIndexPath(outer)
            case .Delete:
                let outer = toOuterIndexPath(indexPath!)
                currentLimit--
                delegate?.portionDataSourceDeleteObjectAtIndexPath(outer)
            case .Update:
                delegate?.portionDataSourceReloadObjectAtIndexPath(toOuterIndexPath(indexPath!))
            case .Move:
                delegate?.portionDataSourceMoveObjectAtIndexPath(toOuterIndexPath(indexPath!), toIndexPath: toOuterIndexPath(newIndexPath!))
        }
    }
}

private extension PortionDataSource {
    func toInnerIndexPath(indexPath: NSIndexPath) -> NSIndexPath {
        let row = indexPath.row + (controller.numberOfRowsForSectionIndex(0) - currentLimit)
        return NSIndexPath(forRow: row, inSection: 0)
    }

    func toOuterIndexPath(indexPath: NSIndexPath) -> NSIndexPath {
        let row = indexPath.row - (controller.numberOfRowsForSectionIndex(0) - currentLimit)
        return NSIndexPath(forRow: row, inSection: 0)
    }
}
