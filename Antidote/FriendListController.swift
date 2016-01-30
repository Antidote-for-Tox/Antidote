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
    func friendListControllerAddFriend(controller: FriendListController)
}

class FriendListController: UIViewController {
    weak var delegate: FriendListControllerDelegate?

    private let theme: Theme

    private let dataSource: FriendListDataSource

    private weak var submanagerFriends: OCTSubmanagerFriends!

    private var tableView: UITableView!

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects, submanagerFriends: OCTSubmanagerFriends) {
        self.theme = theme

        let requestsController = submanagerObjects.fetchedResultsControllerForType(.FriendRequest)
        let friendsController = submanagerObjects.fetchedResultsControllerForType(.Friend, sectionNameKeyPath: "nickname")

        self.dataSource = FriendListDataSource(
                theme: theme,
                requestsController: requestsController,
                friendsController: friendsController)

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
        tableView.snp_makeConstraints {
            $0.edges.equalTo(view)
        }
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
