//
//  FriendListController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 14/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

class FriendListController: UIViewController {
    private let theme: Theme

    private let friendsFetchedController: RBQFetchedResultsController
    private let requestsFetchedController: RBQFetchedResultsController

    private var tableView: UITableView!

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme

        self.friendsFetchedController = submanagerObjects.fetchedResultsControllerForType(.Friend)
        self.requestsFetchedController = submanagerObjects.fetchedResultsControllerForType(.FriendRequest)

        super.init(nibName: nil, bundle: nil)

        self.friendsFetchedController.delegate = self
        self.requestsFetchedController.delegate = self

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

extension FriendListController: RBQFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: RBQFetchedResultsController) {
        tableView.reloadData()
    }
}

extension FriendListController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let request = requestsFetchedController.objectAtIndexPath(indexPath)

        let avatarManager = AvatarManager(theme: theme)

        let model = FriendListCellModel()
        model.avatar = avatarManager.avatarFromString("", diameter: CGFloat(FriendListCell.Constants.AvatarSize))
        model.topText = request.publicKey
        model.bottomText = request.message
        model.multilineBottomtext = true
        model.hideStatus = true

        let cell = FriendListCell()
        cell.setupWithTheme(theme, model: model)

        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestsFetchedController.numberOfRowsForSectionIndex(section)
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return ["R"]
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(localized: "friend_requests_section")
    }
}

extension FriendListController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

private extension FriendListController {
    func createTableView() {
        tableView = UITableView()
        tableView.estimatedRowHeight = 44.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = theme.colorForType(.NormalBackground)
        // removing separators on empty lines
        tableView.tableFooterView = UIView()

        view.addSubview(tableView)
    }

    func installConstraints() {
        tableView.snp_makeConstraints{ make -> Void in
            make.edges.equalTo(view)
        }
    }
}
