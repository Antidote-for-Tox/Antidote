//
//  FriendListDataSource.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 30/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import Foundation

protocol FriendListDataSourceDelegate: class {
    func friendListDataSourceBeginUpdates()
    func friendListDataSourceEndUpdates()

    func friendListDataSourceInsertRowsAtIndexPaths(indexPaths: [NSIndexPath])
    func friendListDataSourceDeleteRowsAtIndexPaths(indexPaths: [NSIndexPath])
    func friendListDataSourceReloadRowsAtIndexPaths(indexPaths: [NSIndexPath])

    func friendListDataSourceInsertSections(sections: NSIndexSet)
    func friendListDataSourceDeleteSections(sections: NSIndexSet)
    func friendListDataSourceReloadSections(sections: NSIndexSet)
}

enum FriendListObject {
    case Request(OCTFriendRequest)
    case Friend(OCTFriend)
}

class FriendListDataSource {
    weak var delegate: FriendListDataSourceDelegate?

    private let requestsController: RBQFetchedResultsController
    private let friendsController: RBQFetchedResultsController

    init(requestsController: RBQFetchedResultsController, friendsController: RBQFetchedResultsController) {
        self.requestsController = requestsController
        self.friendsController = friendsController
    }

    func numberOfSections() -> Int {
        return 0
    }

    func numberOfRowsInSection(section: Int) -> Int {
        return 0
    }

    func modelAtIndexPath(indexPath: NSIndexPath) -> FriendListCellModel {
        return FriendListCellModel()
    }

    func objectAtIndexPath(indexPath: NSIndexPath) -> FriendListObject {
        return .Request(OCTFriendRequest())
    }

    func sectionIndexTitles() -> [String] {
        return [String]()
    }

    func titleForHeaderInSection(section: Int) -> String? {
        return nil
    }

    /**
        Call this method to force the cahce to be rebuilt.
     */
    func reset() {

    }
}
