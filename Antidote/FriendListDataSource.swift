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

    private let requestsStorage: LazyStorage<RBQFetchedResultsController>?
    private let friendsStorage: LazyStorage<RBQFetchedResultsController>

    /// In case if requestsController is nil friend requests won't be shown.
    init(theme: Theme, friendsController: RBQFetchedResultsController, requestsController: RBQFetchedResultsController? = nil) {
        self.avatarManager = AvatarManager(theme: theme)
        self.dateFormatter = NSDateFormatter(type: .RelativeDateAndTime)

        if let requestsController = requestsController {
            self.requestsStorage = LazyStorage(createBlock: {
                requestsController.performFetch()
                return requestsController
            })
        }
        else {
            self.requestsStorage = nil
        }

        self.friendsStorage = LazyStorage(createBlock: {
            friendsController.performFetch()
            return friendsController
        })

        super.init()

        requestsController?.delegate = self
        friendsController.delegate = self
    }

    func numberOfSections() -> Int {
        let requests = requestsStorage?.object.numberOfSections() ?? 0
        let friends = friendsStorage.object.numberOfSections()

        return requests + friends
    }

    func numberOfRowsInSection(section: Int) -> Int {
        if section == Constants.FriendRequestsSection && isRequestsSectionVisible() {
            return requestsStorage!.object.numberOfRowsForSectionIndex(0) ?? 0
        }
        else {
            let normalized = friendsNormalizedSectionFromSection(section)
            return friendsStorage.object.numberOfRowsForSectionIndex(normalized)
        }
    }

    func modelAtIndexPath(indexPath: NSIndexPath) -> FriendListCellModel {
        let model = FriendListCellModel()

        switch objectAtIndexPath(indexPath) {
            case .Request(let request):
                model.avatar = avatarManager.avatarFromString("", diameter: CGFloat(FriendListCell.Constants.AvatarSize))
                model.topText = request.publicKey
                model.bottomText = request.message ?? ""
                model.multilineBottomtext = true
                model.hideStatus = true
            case .Friend(let friend):
                if let data = friend.avatarData {
                    model.avatar = UIImage(data: data)
                }
                else {
                    model.avatar = avatarManager.avatarFromString(friend.nickname, diameter: CGFloat(FriendListCell.Constants.AvatarSize))
                }
                model.topText = friend.nickname

                if friend.isConnected {
                    model.bottomText = friend.statusMessage ?? ""
                }
                else if let date = friend.lastSeenOnline() {
                    model.bottomText = String(localized: "contact_last_seen", dateFormatter.stringFromDate(date))
                }

                model.status = UserStatus(connectionStatus: friend.connectionStatus, userStatus: friend.status)
        }

        return model
    }

    func objectAtIndexPath(indexPath: NSIndexPath) -> FriendListObject {
        if indexPath.section == Constants.FriendRequestsSection && isRequestsSectionVisible() {
            return .Request(requestsStorage!.object.objectAtIndexPath(indexPath) as! OCTFriendRequest)
        }
        else {
            let section = friendsNormalizedSectionFromSection(indexPath.section)
            let normalized = NSIndexPath(forRow: indexPath.row, inSection: section)

            return .Friend(friendsStorage.object.objectAtIndexPath(normalized) as! OCTFriend)
        }
    }

    func sectionIndexTitles() -> [String] {
        var array = [String]()

        for i in 0..<friendsStorage.object.numberOfSections() {
            array.append(friendsStorage.object.titleForHeaderInSection(i))
        }

        return array.filter {
            !$0.isEmpty
        }.map {
            $0.substringToIndex($0.startIndex.advancedBy(1))
        }
    }

    func titleForHeaderInSection(section: Int) -> String? {
        if section == Constants.FriendRequestsSection && isRequestsSectionVisible() {
            return String(localized: "contact_requests_section")
        }
        else {
            let normalized = friendsNormalizedSectionFromSection(section)
            let title = friendsStorage.object.titleForHeaderInSection(normalized)

            return title.isEmpty ? "" : title.substringToIndex(title.startIndex.advancedBy(1))
        }
    }

    /**
        Call this method to force the cahce to be rebuilt.
     */
    func reset() {
        requestsStorage?.object.reset()
        friendsStorage.object.reset()
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
        guard let requestsStorage = requestsStorage else {
            return false
        }
        return requestsStorage.object.numberOfSections() > 0
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
        if requestsStorage != nil && controller == requestsStorage!.object {
            return index
        }

        // friends controller
        return isRequestsSectionVisible() ? (index + 1) : index
    }
}
