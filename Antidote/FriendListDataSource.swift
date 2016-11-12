// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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

    func friendListDataSourceReloadTable()
}

enum FriendListObject {
    case Request(OCTFriendRequest)
    case Friend(OCTFriend)
}

class FriendListDataSource: NSObject {
    weak var delegate: FriendListDataSourceDelegate?

    private let avatarManager: AvatarManager
    private let dateFormatter: NSDateFormatter

    private let requests: Results<OCTFriendRequest>?
    private let friends: Results<OCTFriend>

    private var requestsToken: RLMNotificationToken?
    private var friendsToken: RLMNotificationToken?

    /// In case if requests is nil friend requests won't be shown.
    init(theme: Theme, friends: Results<OCTFriend>, requests: Results<OCTFriendRequest>? = nil) {
        self.avatarManager = AvatarManager(theme: theme)
        self.dateFormatter = NSDateFormatter(type: .RelativeDateAndTime)

        self.requests = requests
        self.friends = friends

        super.init()

        addNotificationBlocks()
    }

    deinit {
        requestsToken?.stop()
        friendsToken?.stop()
    }

    func numberOfSections() -> Int {
        if isRequestsSectionVisible() {
            return 2
        }

        // friends only
        return 1
    }

    func numberOfRowsInSection(section: Int) -> Int {
        if section == Constants.FriendRequestsSection && isRequestsSectionVisible() {
            return requests!.count
        }
        else {
            return friends.count
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

                model.accessibilityLabel = String(localized: "contact_request")
                model.accessibilityValue = ""

                if let message = request.message {
                    model.accessibilityValue += String(localized: "add_contact_default_message_title") + ": " + message + ", "
                }
                model.accessibilityValue += String(localized: "public_key") + ": " + request.publicKey

            case .Friend(let friend):
                if let data = friend.avatarData {
                    model.avatar = UIImage(data: data)
                }
                else {
                    model.avatar = avatarManager.avatarFromString(friend.nickname, diameter: CGFloat(FriendListCell.Constants.AvatarSize))
                }
                model.topText = friend.nickname

                model.status = UserStatus(connectionStatus: friend.connectionStatus, userStatus: friend.status)

                model.accessibilityLabel = friend.nickname
                model.accessibilityValue = model.status.toString()

                if friend.isConnected {
                    model.bottomText = friend.statusMessage ?? ""
                    model.accessibilityValue += ", Status: \(model.bottomText)"
                }
                else if let date = friend.lastSeenOnline() {
                    model.bottomText = String(localized: "contact_last_seen", dateFormatter.stringFromDate(date))
                    model.accessibilityValue += ", " + model.bottomText
                }
        }

        return model
    }

    func objectAtIndexPath(indexPath: NSIndexPath) -> FriendListObject {
        if indexPath.section == Constants.FriendRequestsSection && isRequestsSectionVisible() {
            return .Request(requests![indexPath.row])
        }
        else {
            return .Friend(friends[indexPath.row])
        }
    }

    func sectionIndexTitles() -> [String] {
        // TODO fix when Realm will support sections
        let array = [String]()
        return array
    }

    func titleForHeaderInSection(section: Int) -> String? {
        if !isRequestsSectionVisible() {
            return nil
        }

        if section == Constants.FriendRequestsSection {
            return String(localized: "contact_requests_section")
        }
        else {
            return String(localized: "contacts_title")
        }
    }
}

private extension FriendListDataSource {
    func addNotificationBlocks() {
        requestsToken = requests?.addNotificationBlock { [unowned self] change in
            switch change {
                case .Initial:
                    break
                case .Update(let requests, let deletions, let insertions, let modifications):
                    guard let requests = requests else {
                        return
                    }

                    if deletions.count > 0 {
                        // reloading data on request removal/friend insertion to synchronize requests/friends
                        self.delegate?.friendListDataSourceReloadTable()
                        return
                    }

                    self.delegate?.friendListDataSourceBeginUpdates()

                    let countAfter = requests.count
                    let countBefore = countAfter - insertions.count + deletions.count

                    if countBefore == 0 && countAfter > 0 {
                        self.delegate?.friendListDataSourceInsertSections(NSIndexSet(index: 0))
                    }
                    else if countBefore > 0 && countAfter == 0 {
                        self.delegate?.friendListDataSourceDeleteSections(NSIndexSet(index: 0))
                    }
                    else {
                        self.delegate?.friendListDataSourceDeleteRowsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: 0)} )
                        self.delegate?.friendListDataSourceInsertRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: 0)} )
                        self.delegate?.friendListDataSourceReloadRowsAtIndexPaths(modifications.map { NSIndexPath(forRow: $0, inSection: 0)} )
                    }

                    self.delegate?.friendListDataSourceEndUpdates()
                case .Error(let error):
                    fatalError("\(error)")
            }
        }

        friendsToken = friends.addNotificationBlock { [unowned self] change in
            switch change {
                case .Initial:
                    break
                case .Update(_, let deletions, let insertions, let modifications):
                    if insertions.count > 0 {
                        // reloading data on request removal/friend insertion to synchronize requests/friends
                        self.delegate?.friendListDataSourceReloadTable()
                        return
                    }

                    let section = self.isRequestsSectionVisible() ? 1 : 0

                    let deletions = deletions.map { NSIndexPath(forRow: $0, inSection: section) }
                    let insertions = insertions.map { NSIndexPath(forRow: $0, inSection: section) }
                    let modifications = modifications.map { NSIndexPath(forRow: $0, inSection: section) }

                    self.delegate?.friendListDataSourceBeginUpdates()
                    self.delegate?.friendListDataSourceDeleteRowsAtIndexPaths(deletions)
                    self.delegate?.friendListDataSourceInsertRowsAtIndexPaths(insertions)
                    self.delegate?.friendListDataSourceReloadRowsAtIndexPaths(modifications)
                    self.delegate?.friendListDataSourceEndUpdates()
                case .Error(let error):
                    fatalError("\(error)")
            }
        }
    }

    func isRequestsSectionVisible() -> Bool {
        guard let requests = requests else {
            return false
        }

        return requests.count > 0
    }
}
