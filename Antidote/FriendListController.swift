//
//  FriendListController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 14/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let FriendRequestsSection = 0
}

protocol FriendListControllerDelegate: class {
    func friendListController(controller: FriendListController, didSelectFriend friend: OCTFriend)
    func friendListControllerAddFriend(controller: FriendListController)
}

class FriendListController: UIViewController {
    weak var delegate: FriendListControllerDelegate?

    private let theme: Theme

    private let dataSource: FriendListDataSource

    private let avatarManager: AvatarManager
    private let submanagerFriends: OCTSubmanagerFriends

    private var tableView: UITableView!

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects, submanagerFriends: OCTSubmanagerFriends) {
        self.theme = theme

        let requestsController = submanagerObjects.fetchedResultsControllerForType(.FriendRequest)
        let friendsController = submanagerObjects.fetchedResultsControllerForType(.Friend, sectionNameKeyPath: "nickname")

        self.dataSource = FriendListDataSource(requestsController: requestsController, friendsController: friendsController)

        self.avatarManager = AvatarManager(theme: theme)
        self.submanagerFriends = submanagerFriends

        super.init(nibName: nil, bundle: nil)

        addNavigationButtons()

        dataSource.delegate = self

        edgesForExtendedLayout = .None
        title = String(localized: "friends_title")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        createTableView()
        installConstraints()
    }
}

extension FriendListController {
    func addFriendButtonPressed() {
        delegate?.friendListControllerAddFriend(self)
    }
}

extension FriendListController: FriendListDataSourceDelegate {
    func friendListDataSourceBeginUpdates() {
        tableView.beginUpdates()
    }

    func friendListDataSourceEndUpdates() {
        ExceptionHandling.tryWithBlock({ [unowned self] in
            self.tableView.endUpdates()
        }) { [unowned self] _ in
            self.dataSource.reset()
            self.tableView.reloadData()
        }
    }

    func friendListDataSourceInsertRowsAtIndexPaths(indexPaths: [NSIndexPath]) {
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }

    func friendListDataSourceDeleteRowsAtIndexPaths(indexPaths: [NSIndexPath]) {
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }

    func friendListDataSourceReloadRowsAtIndexPaths(indexPaths: [NSIndexPath]) {
        tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }

    func friendListDataSourceInsertSections(sections: NSIndexSet) {
        tableView.insertSections(sections, withRowAnimation: .Automatic)
    }

    func friendListDataSourceDeleteSections(sections: NSIndexSet) {
        tableView.deleteSections(sections, withRowAnimation: .Automatic)
    }

    func friendListDataSourceReloadSections(sections: NSIndexSet) {
        tableView.reloadSections(sections, withRowAnimation: .Automatic)
    }
}

extension FriendListController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(FriendListCell.staticReuseIdentifier) as! FriendListCell
        let model = dataSource.modelAtIndexPath(indexPath)

        // if indexPath.section == Constants.FriendRequestsSection && isRequestsSectionVisible() {
        //     let request = requestAtIndexPath(indexPath)

        //     model.avatar = avatarManager.avatarFromString("", diameter: CGFloat(FriendListCell.Constants.AvatarSize))
        //     model.topText = request.publicKey
        //     model.bottomText = request.message
        //     model.multilineBottomtext = true
        //     model.hideStatus = true
        // }
        // else {
        //     let friend = friendAtIndexPath(indexPath)

        //     model.avatar = avatarManager.avatarFromString(friend.nickname, diameter: CGFloat(FriendListCell.Constants.AvatarSize))
        //     model.topText = friend.nickname

        //     if friend.isConnected {
        //         model.bottomText = friend.statusMessage
        //     }
        //     else if friend.lastSeenOnline() != nil {
        //         model.bottomText = String(localized: "friend_last_seen", friend.lastSeenOnline())
        //     }

        //     model.status = UserStatus(connectionStatus: friend.connectionStatus, userStatus: friend.status)
        // }

        cell.setupWithTheme(theme, model: model)

        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
        // let requests = isRequestsSectionVisible() ? 1 : 0
        // let friends = friendsFetchedController.numberOfSections()

        // return requests + friends
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfRowsInSection(section)
        // if section == Constants.FriendRequestsSection && isRequestsSectionVisible() {
        //     return requestsFetchedController.numberOfRowsForSectionIndex(0)
        // }
        // else {
        //     let normalized = friendsNormalizedSectionFromSection(section)
        //     return friendsFetchedController.numberOfRowsForSectionIndex(normalized)
        // }
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return dataSource.sectionIndexTitles()
        // var array = [String]()

        // for i in 0..<friendsFetchedController.numberOfSections() {
        //     array.append(friendsFetchedController.titleForHeaderInSection(i))
        // }

        // return array.filter {
        //     !$0.isEmpty
        // }.map {
        //     $0.substringToIndex($0.startIndex.advancedBy(1))
        // }
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.titleForHeaderInSection(section)
        // if section == Constants.FriendRequestsSection && isRequestsSectionVisible() {
        //     return String(localized: "friend_requests_section")
        // }
        // else {
        //     let normalized = friendsNormalizedSectionFromSection(section)
        //     let title = friendsFetchedController.titleForHeaderInSection(normalized)

        //     return title.isEmpty ? "" : title.substringToIndex(title.startIndex.advancedBy(1))
        // }
    }
}

extension FriendListController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        switch dataSource.objectAtIndexPath(indexPath) {
            case .Request(let request):
                didSelectFriendRequest(request)
            case .Friend(let friend):
                delegate?.friendListController(self, didSelectFriend: friend)
        }
    }
}

private extension FriendListController {
    func addNavigationButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .Add,
                target: self,
                action: "addFriendButtonPressed")
    }

    func createTableView() {
        tableView = UITableView()
        tableView.estimatedRowHeight = 44.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = theme.colorForType(.NormalBackground)
        tableView.sectionIndexColor = theme.colorForType(.LinkText)
        // removing separators on empty lines
        tableView.tableFooterView = UIView()

        view.addSubview(tableView)

        tableView.registerClass(FriendListCell.self, forCellReuseIdentifier: FriendListCell.staticReuseIdentifier)
    }

    func installConstraints() {
        tableView.snp_makeConstraints{ make -> Void in
            make.edges.equalTo(view)
        }
    }

    // func isRequestsSectionVisible() -> Bool {
    //     return requestsFetchedController.numberOfRowsForSectionIndex(0) > 0
    // }

    // func requestAtIndexPath(indexPath: NSIndexPath) -> OCTFriendRequest {
    //     assert(isRequestsSectionVisible(), "Friend requests shouldn't be visible at the moment")
    //     assert(indexPath.section == Constants.FriendRequestsSection, "Wrong section used for accessing friend request")

    //     let normalized = NSIndexPath(forRow: indexPath.row, inSection: 0)

    //     return requestsFetchedController.objectAtIndexPath(normalized) as! OCTFriendRequest
    // }

    // func friendAtIndexPath(indexPath: NSIndexPath) -> OCTFriend {
    //     assert(!isRequestsSectionVisible() || indexPath.section != Constants.FriendRequestsSection, "Wrong section used for accessing friend")

    //     let section = friendsNormalizedSectionFromSection(indexPath.section)

    //     let normalized = NSIndexPath(forRow: indexPath.row, inSection: section)

    //     return friendsFetchedController.objectAtIndexPath(normalized) as! OCTFriend
    // }

    // func friendsNormalizedSectionFromSection(section: Int) -> Int {
    //     if isRequestsSectionVisible() && section > Constants.FriendRequestsSection {
    //         return section - 1
    //     }

    //     return section
    // }

    func didSelectFriendRequest(request: OCTFriendRequest) {
        // FIXME: replace with request controller or some buttons on cell
        let alert = UIAlertController(title: nil, message: "Choose action", preferredStyle: .Alert)

        alert.addAction(UIAlertAction(title: "Add friend", style: .Default) { [unowned self] _ -> Void in
            _ = try? self.submanagerFriends.approveFriendRequest(request)
        })

        alert.addAction(UIAlertAction(title: "Remove friend", style: .Destructive) { [unowned self] _ -> Void in
            self.submanagerFriends.removeFriendRequest(request)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))

        presentViewController(alert, animated: true, completion: nil)
    }
}
