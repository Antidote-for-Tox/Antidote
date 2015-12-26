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

    private let requestsFetchedController: RBQFetchedResultsController
    private let friendsFetchedController: RBQFetchedResultsController

    private let avatarManager: AvatarManager
    private let submanagerFriends: OCTSubmanagerFriends

    private var tableView: UITableView!

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects, submanagerFriends: OCTSubmanagerFriends) {
        self.theme = theme

        self.requestsFetchedController = submanagerObjects.fetchedResultsControllerForType(.FriendRequest)
        self.friendsFetchedController = submanagerObjects.fetchedResultsControllerForType(
                .Friend,
                sectionNameKeyPath: "nickname")

        self.avatarManager = AvatarManager(theme: theme)
        self.submanagerFriends = submanagerFriends

        super.init(nibName: nil, bundle: nil)

        requestsFetchedController.delegate = self
        friendsFetchedController.delegate = self

        addNavigationButtons()

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

extension FriendListController: RBQFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: RBQFetchedResultsController) {
        tableView.reloadData()
    }
}

extension FriendListController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(FriendListCell.staticReuseIdentifier) as! FriendListCell
        let model = FriendListCellModel()

        if indexPath.section == Constants.FriendRequestsSection && isRequestsSectionVisible() {
            let request = requestAtIndexPath(indexPath)

            model.avatar = avatarManager.avatarFromString("", diameter: CGFloat(FriendListCell.Constants.AvatarSize))
            model.topText = request.publicKey
            model.bottomText = request.message
            model.multilineBottomtext = true
            model.hideStatus = true
        }
        else {
            let friend = friendAtIndexPath(indexPath)

            model.avatar = avatarManager.avatarFromString(friend.nickname, diameter: CGFloat(FriendListCell.Constants.AvatarSize))
            model.topText = friend.nickname

            if friend.isConnected {
                model.bottomText = friend.statusMessage
            }
            else if friend.lastSeenOnline() != nil {
                model.bottomText = String(localized: "friend_last_seen", friend.lastSeenOnline())
            }

            model.status = UserStatus(connectionStatus: friend.connectionStatus, userStatus: friend.status)
        }

        cell.setupWithTheme(theme, model: model)

        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let requests = isRequestsSectionVisible() ? 1 : 0
        let friends = friendsFetchedController.numberOfSections()

        return requests + friends
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Constants.FriendRequestsSection && isRequestsSectionVisible() {
            return requestsFetchedController.numberOfRowsForSectionIndex(0)
        }
        else {
            let normalized = friendsNormalizedSectionFromSection(section)
            return friendsFetchedController.numberOfRowsForSectionIndex(normalized)
        }
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        var array = [String]()

        for i in 0..<friendsFetchedController.numberOfSections() {
            array.append(friendsFetchedController.titleForHeaderInSection(i))
        }

        return array.filter {
            !$0.isEmpty
        }.map {
            $0.substringToIndex($0.startIndex.advancedBy(1))
        }
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == Constants.FriendRequestsSection && isRequestsSectionVisible() {
            return String(localized: "friend_requests_section")
        }
        else {
            let normalized = friendsNormalizedSectionFromSection(section)
            return friendsFetchedController.titleForHeaderInSection(normalized)
        }
    }
}

extension FriendListController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.section == Constants.FriendRequestsSection && isRequestsSectionVisible() {
            let request = requestAtIndexPath(indexPath)
            didSelectFriendRequest(request)
        }
        else {
            let friend = friendAtIndexPath(indexPath)
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

    func isRequestsSectionVisible() -> Bool {
        return requestsFetchedController.numberOfRowsForSectionIndex(0) > 0
    }

    func requestAtIndexPath(indexPath: NSIndexPath) -> OCTFriendRequest {
        assert(isRequestsSectionVisible(), "Friend requests shouldn't be visible at the moment")
        assert(indexPath.section == Constants.FriendRequestsSection, "Wrong section used for accessing friend request")

        let normalized = NSIndexPath(forRow: indexPath.row, inSection: 0)

        return requestsFetchedController.objectAtIndexPath(normalized) as! OCTFriendRequest
    }

    func friendAtIndexPath(indexPath: NSIndexPath) -> OCTFriend {
        assert(indexPath.section != Constants.FriendRequestsSection, "Wrong section used for accessing friend")

        var section = friendsNormalizedSectionFromSection(indexPath.section)

        let normalized = NSIndexPath(forRow: indexPath.row, inSection: section)

        return friendsFetchedController.objectAtIndexPath(normalized) as! OCTFriend
    }

    func friendsNormalizedSectionFromSection(section: Int) -> Int {
        if isRequestsSectionVisible() && section > Constants.FriendRequestsSection {
            return section - 1
        }

        return section
    }

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
