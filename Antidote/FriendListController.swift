//
//  FriendListController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 14/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

protocol FriendListControllerDelegate: class {
    func friendListController(controller: FriendListController, didSelectFriend friend: OCTFriend)
    func friendListController(controller: FriendListController, didSelectRequest request: OCTFriendRequest)
    func friendListControllerAddFriend(controller: FriendListController)
}

class FriendListController: UIViewController {
    weak var delegate: FriendListControllerDelegate?

    private let theme: Theme

    private let dataSource: FriendListDataSource

    private weak var submanagerFriends: OCTSubmanagerFriends!
    private weak var submanagerChats: OCTSubmanagerChats!

    private var tableView: UITableView!

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects, submanagerFriends: OCTSubmanagerFriends, submanagerChats: OCTSubmanagerChats) {
        self.theme = theme

        let requestsController = submanagerObjects.fetchedResultsControllerForType(.FriendRequest)
        let friendsController = submanagerObjects.fetchedResultsControllerForType(.Friend, sectionNameKeyPath: "nickname")

        self.dataSource = FriendListDataSource(
                theme: theme,
                requestsController: requestsController,
                friendsController: friendsController)

        self.submanagerFriends = submanagerFriends
        self.submanagerChats = submanagerChats

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

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        tableView.setEditing(editing, animated: animated)
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

        cell.setupWithTheme(theme, model: model)

        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfRowsInSection(section)
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return dataSource.sectionIndexTitles()
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.titleForHeaderInSection(section)
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let title: String

            switch dataSource.objectAtIndexPath(indexPath) {
                case .Request:
                    title = String(localized:"delete_friend_request_title")
                case .Friend:
                    title = String(localized:"delete_friend_title")
            }

            let alert = UIAlertController(title: title, message: nil, preferredStyle: .Alert)

            alert.addAction(UIAlertAction(title: String(localized: "alert_cancel"), style: .Default, handler: nil))
            alert.addAction(UIAlertAction(title: String(localized: "alert_delete"), style: .Destructive) { [unowned self] _ -> Void in
                switch self.dataSource.objectAtIndexPath(indexPath) {
                    case .Request(let request):
                        self.submanagerFriends.removeFriendRequest(request)
                    case .Friend(let friend):
                        do {
                            let chat = self.submanagerChats.getOrCreateChatWithFriend(friend)

                            try self.submanagerFriends.removeFriend(friend)

                            self.submanagerChats.removeChatWithAllMessages(chat)
                        }
                        catch let error as NSError {
                            handleErrorWithType(.RemoveFriend, error: error)
                        }
                }
            })

            presentViewController(alert, animated: true, completion: nil)
        }
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
        navigationItem.leftBarButtonItem = editButtonItem()

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
        tableView.snp_makeConstraints {
            $0.edges.equalTo(view)
        }
    }

    func didSelectFriendRequest(request: OCTFriendRequest) {
        delegate?.friendListController(self, didSelectRequest: request)
    }
}
