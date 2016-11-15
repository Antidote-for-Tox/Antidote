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

    func friendListDataSourceInsertRowsAtIndexPaths(_ indexPaths: [IndexPath])
    func friendListDataSourceDeleteRowsAtIndexPaths(_ indexPaths: [IndexPath])
    func friendListDataSourceReloadRowsAtIndexPaths(_ indexPaths: [IndexPath])

    func friendListDataSourceInsertSections(_ sections: IndexSet)
    func friendListDataSourceDeleteSections(_ sections: IndexSet)
    func friendListDataSourceReloadSections(_ sections: IndexSet)

    func friendListDataSourceReloadTable()
}

enum FriendListObject {
    case request(OCTFriendRequest)
    case friend(OCTFriend)
}

class FriendListDataSource: NSObject {
    weak var delegate: FriendListDataSourceDelegate?

    fileprivate let avatarManager: AvatarManager
    fileprivate let dateFormatter: DateFormatter

    fileprivate let requests: Results<OCTFriendRequest>?
    fileprivate let friends: Results<OCTFriend>

    fileprivate var requestsToken: RLMNotificationToken?
    fileprivate var friendsToken: RLMNotificationToken?

    /// In case if requests is nil friend requests won't be shown.
    init(theme: Theme, friends: Results<OCTFriend>, requests: Results<OCTFriendRequest>? = nil) {
        self.avatarManager = AvatarManager(theme: theme)
        self.dateFormatter = DateFormatter(type: .relativeDateAndTime)

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

    func numberOfRowsInSection(_ section: Int) -> Int {
        if section == Constants.FriendRequestsSection && isRequestsSectionVisible() {
            return requests!.count
        }
        else {
            return friends.count
        }
    }

    func modelAtIndexPath(_ indexPath: IndexPath) -> FriendListCellModel {
        let model = FriendListCellModel()

        switch objectAtIndexPath(indexPath) {
            case .request(let request):
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

            case .friend(let friend):
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
                    model.bottomText = String(localized: "contact_last_seen", dateFormatter.string(from: date))
                    model.accessibilityValue += ", " + model.bottomText
                }
        }

        return model
    }

    func objectAtIndexPath(_ indexPath: IndexPath) -> FriendListObject {
        if indexPath.section == Constants.FriendRequestsSection && isRequestsSectionVisible() {
            return .request(requests![indexPath.row])
        }
        else {
            return .friend(friends[indexPath.row])
        }
    }

    func sectionIndexTitles() -> [String] {
        // TODO fix when Realm will support sections
        let array = [String]()
        return array
    }

    func titleForHeaderInSection(_ section: Int) -> String? {
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
                case .initial:
                    break
                case .update(let requests, let deletions, let insertions, let modifications):
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
                        self.delegate?.friendListDataSourceInsertSections(IndexSet(integer: 0))
                    }
                    else if countBefore > 0 && countAfter == 0 {
                        self.delegate?.friendListDataSourceDeleteSections(IndexSet(integer: 0))
                    }
                    else {
                        self.delegate?.friendListDataSourceDeleteRowsAtIndexPaths(deletions.map { IndexPath(row: $0, section: 0)} )
                        self.delegate?.friendListDataSourceInsertRowsAtIndexPaths(insertions.map { IndexPath(row: $0, section: 0)} )
                        self.delegate?.friendListDataSourceReloadRowsAtIndexPaths(modifications.map { IndexPath(row: $0, section: 0)} )
                    }

                    self.delegate?.friendListDataSourceEndUpdates()
                case .error(let error):
                    fatalError("\(error)")
            }
        }

        friendsToken = friends.addNotificationBlock { [unowned self] change in
            switch change {
                case .initial:
                    break
                case .update(_, let deletions, let insertions, let modifications):
                    if insertions.count > 0 {
                        // reloading data on request removal/friend insertion to synchronize requests/friends
                        self.delegate?.friendListDataSourceReloadTable()
                        return
                    }

                    let section = self.isRequestsSectionVisible() ? 1 : 0

                    let deletions = deletions.map { IndexPath(row: $0, section: section) }
                    let insertions = insertions.map { IndexPath(row: $0, section: section) }
                    let modifications = modifications.map { IndexPath(row: $0, section: section) }

                    self.delegate?.friendListDataSourceBeginUpdates()
                    self.delegate?.friendListDataSourceDeleteRowsAtIndexPaths(deletions)
                    self.delegate?.friendListDataSourceInsertRowsAtIndexPaths(insertions)
                    self.delegate?.friendListDataSourceReloadRowsAtIndexPaths(modifications)
                    self.delegate?.friendListDataSourceEndUpdates()
                case .error(let error):
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
