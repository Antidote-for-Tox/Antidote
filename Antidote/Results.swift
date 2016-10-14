// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/// Swift wrapper for RLMResults
class Results<T: OCTObject> {
    private let results: RLMResults

    var count: Int {
        get {
            return Int(results.count)
        }
    }

    var firstObject: T {
        get {
            return results.firstObject() as! T
        }
    }

    var lastObject: T {
        get {
            return results.lastObject() as! T
        }
    }

    init(results: RLMResults) {
        let name = NSStringFromClass(T.self)
        assert(name == results.objectClassName, "Specified wrong generic class")

        self.results = results
    }

    func indexOfObject(object: T) -> Int {
        return Int(results.indexOfObject(object))
    }

    func sortedResultsUsingProperty(property: String, ascending: Bool) -> Results<T> {
        let sortedResults = results.sortedResultsUsingProperty(property, ascending: ascending)
        return Results<T>(results: sortedResults)
    }

    func sortedResultsUsingDescriptors(properties: Array<RLMSortDescriptor>) -> Results<T> {
        let sortedResults = results.sortedResultsUsingDescriptors(properties)
        return Results<T>(results: sortedResults)
    }

    func addNotificationBlock(block: ResultsChange<T> -> Void) -> RLMNotificationToken {
        return results.addNotificationBlock { rlmResults, changes, error in
            if let error = error {
                block(ResultsChange.Error(error))
                return
            }

            let results: Results<T>? = (rlmResults != nil) ? Results<T>(results: rlmResults!) : nil

            if let changes = changes {
                block(ResultsChange.Update(results,
                                           deletions: changes.deletions as! [Int],
                                           insertions: changes.insertions as! [Int],
                                           modifications: changes.modifications as! [Int]))
                return
            }

            block(ResultsChange.Initial(results))
        }
    }

    subscript(index: Int) -> T {
        return results[UInt(index)] as! T
    }
}
