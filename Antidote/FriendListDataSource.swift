//
//  FriendListDataSource.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 30/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import Foundation

private struct Constants {
    static let FriendRequestsSection = 0
}

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

class FriendListDataSource: NSObject {
    weak var delegate: FriendListDataSourceDelegate?

    private let avatarManager: AvatarManager
    private let dateFormatter: NSDateFormatter

    private let requestsControllerStorage: RBQFetchedResultsController
    private let friendsControllerStorage: RBQFetchedResultsController

    private lazy var fetchedRequestsController: RBQFetchedResultsController = { [unowned self] in
        self.requestsControllerStorage.performFetch()
        return self.requestsControllerStorage
    }()

    private lazy var fetchedFriendsController: RBQFetchedResultsController = { [unowned self] in
        self.friendsControllerStorage.performFetch()
        return self.friendsControllerStorage
    }()

    init(theme: Theme, requestsController: RBQFetchedResultsController, friendsController: RBQFetchedResultsController) {
        self.avatarManager = AvatarManager(theme: theme)
        self.dateFormatter = NSDateFormatter(type: .RelativeDateAndTime)

        self.requestsControllerStorage = requestsController
        self.friendsControllerStorage = friendsController

        super.init()

        requestsController.delegate = self
        friendsController.delegate = self
    }

    func numberOfSections() -> Int {
        let requests = fetchedRequestsController.numberOfSections()
        let friends = fetchedFriendsController.numberOfSections()

        return requests + friends
    }

    func numberOfRowsInSection(section: Int) -> Int {
        if section == Constants.FriendRequestsSection && isRequestsSectionVisible() {
            return fetchedRequestsController.numberOfRowsForSectionIndex(0)
        }
        else {
            let normalized = friendsNormalizedSectionFromSection(section)
            return fetchedFriendsController.numberOfRowsForSectionIndex(normalized)
        }
    }

    func modelAtIndexPath(indexPath: NSIndexPath) -> FriendListCellModel {
        let model = FriendListCellModel()

        switch objectAtIndexPath(indexPath) {
            case .Request(let request):
                model.avatar = avatarManager.avatarFromString("", diameter: CGFloat(FriendListCell.Constants.AvatarSize))
                model.topText = request.publicKey
                model.bottomText = request.message
                model.multilineBottomtext = true
                model.hideStatus = true
            case .Friend(let friend):
                model.avatar = avatarManager.avatarFromString(friend.nickname, diameter: CGFloat(FriendListCell.Constants.AvatarSize))
                model.topText = friend.nickname

                if friend.isConnected {
                    model.bottomText = friend.statusMessage
                }
                else if friend.lastSeenOnline() != nil {
                    model.bottomText = String(
                            localized: "friend_last_seen",
                            dateFormatter.stringFromDate(friend.lastSeenOnline()))
                }

                model.status = UserStatus(connectionStatus: friend.connectionStatus, userStatus: friend.status)
        }

        return model
    }

    func objectAtIndexPath(indexPath: NSIndexPath) -> FriendListObject {
        if indexPath.section == Constants.FriendRequestsSection && isRequestsSectionVisible() {
            return .Request(fetchedRequestsController.objectAtIndexPath(indexPath) as! OCTFriendRequest)
        }
        else {
            let section = friendsNormalizedSectionFromSection(indexPath.section)
            let normalized = NSIndexPath(forRow: indexPath.row, inSection: section)

            return .Friend(fetchedFriendsController.objectAtIndexPath(normalized) as! OCTFriend)
        }
    }

    func sectionIndexTitles() -> [String] {
        var array = [String]()

        for i in 0..<fetchedFriendsController.numberOfSections() {
            array.append(fetchedFriendsController.titleForHeaderInSection(i))
        }

        return array.filter {
            !$0.isEmpty
        }.map {
            $0.substringToIndex($0.startIndex.advancedBy(1))
        }
    }

    func titleForHeaderInSection(section: Int) -> String? {
        if section == Constants.FriendRequestsSection && isRequestsSectionVisible() {
            return String(localized: "friend_requests_section")
        }
        else {
            let normalized = friendsNormalizedSectionFromSection(section)
            let title = fetchedFriendsController.titleForHeaderInSection(normalized)

            return title.isEmpty ? "" : title.substringToIndex(title.startIndex.advancedBy(1))
        }
    }

    /**
        Call this method to force the cahce to be rebuilt.
     */
    func reset() {
        fetchedRequestsController.reset()
        fetchedFriendsController.reset()
    }
}

extension FriendListDataSource: RBQFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: RBQFetchedResultsController) {
        delegate?.friendListDataSourceBeginUpdates()
    }

   func controllerDidChangeContent(controller: RBQFetchedResultsController) {
       delegate?.friendListDataSourceEndUpdates()
   }

    func controller(
            controller: RBQFetchedResultsController,
            didChangeObject anObject: RBQSafeRealmObject,
            atIndexPath indexPath: NSIndexPath?,
            forChangeType type: RBQFetchedResultsChangeType,
            newIndexPath: NSIndexPath?) {

        let denormalizedPath = denormalizeIndexPath(indexPath, forController: controller)
        let newDenormalizedPath = denormalizeIndexPath(newIndexPath, forController: controller)

        switch type {
            case .Insert:
                delegate?.friendListDataSourceInsertRowsAtIndexPaths([newDenormalizedPath!])
            case .Delete:
                delegate?.friendListDataSourceDeleteRowsAtIndexPaths([denormalizedPath!])
            case .Move:
                delegate?.friendListDataSourceDeleteRowsAtIndexPaths([denormalizedPath!])
                delegate?.friendListDataSourceInsertRowsAtIndexPaths([newDenormalizedPath!])
            case .Update:
                delegate?.friendListDataSourceReloadRowsAtIndexPaths([denormalizedPath!])
        }
    }

    func controller(
            controller: RBQFetchedResultsController,
            didChangeSection section: RBQFetchedResultsSectionInfo,
            atIndex sectionIndex: UInt,
            forChangeType type: RBQFetchedResultsChangeType) {

        let denormalizedIndex = denormalizeSectionIndex(Int(sectionIndex), forController: controller)
        let indexSet = NSIndexSet(index: denormalizedIndex)

        switch type {
            case .Insert:
                delegate?.friendListDataSourceInsertSections(indexSet)
            case .Delete:
                delegate?.friendListDataSourceDeleteSections(indexSet)
            case .Move:
                // nop
                break
            case .Update:
                delegate?.friendListDataSourceReloadSections(indexSet)
        }
    }
}

private extension FriendListDataSource {
    func isRequestsSectionVisible() -> Bool {
        return fetchedRequestsController.numberOfSections() > 0
    }

    func friendsNormalizedSectionFromSection(section: Int) -> Int {
        if isRequestsSectionVisible() && section > Constants.FriendRequestsSection {
            return section - 1
        }

        return section
    }

    func denormalizeIndexPath(indexPath: NSIndexPath?, forController controller: RBQFetchedResultsController) -> NSIndexPath? {
        guard indexPath != nil else {
            return nil
        }

        let denormalizedIndex = denormalizeSectionIndex(indexPath!.section, forController: controller)
        return NSIndexPath(forRow: indexPath!.row, inSection: denormalizedIndex)
    }

    func denormalizeSectionIndex(index: Int, forController controller: RBQFetchedResultsController) -> Int {
        if controller == fetchedRequestsController {
            return index
        }

        // friends controller
        return isRequestsSectionVisible() ? (index - 1) : index
    }
}
