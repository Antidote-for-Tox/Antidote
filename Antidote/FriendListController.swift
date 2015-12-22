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

class FriendListController: UIViewController {
    private let theme: Theme

    private let friendsFetchedController: RBQFetchedResultsController
    private let requestsFetchedController: RBQFetchedResultsController

    private let avatarManager: AvatarManager
    private let submanagerFriends: OCTSubmanagerFriends

    private var tableView: UITableView!

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects, submanagerFriends: OCTSubmanagerFriends) {
        self.theme = theme

        self.friendsFetchedController = submanagerObjects.fetchedResultsControllerForType(.Friend)
        self.requestsFetchedController = submanagerObjects.fetchedResultsControllerForType(.FriendRequest)

        self.avatarManager = AvatarManager(theme: theme)
        self.submanagerFriends = submanagerFriends

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
        let cell = tableView.dequeueReusableCellWithIdentifier(FriendListCell.staticReuseIdentifier) as! FriendListCell
        let model = FriendListCellModel()

        switch indexPath.section {
            case Constants.FriendRequestsSection:
                let request = requestAtIndexPath(indexPath)

                model.avatar = avatarManager.avatarFromString("", diameter: CGFloat(FriendListCell.Constants.AvatarSize))
                model.topText = request.publicKey
                model.bottomText = request.message
                model.multilineBottomtext = true
                model.hideStatus = true
            default:
                break
        }

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

        switch indexPath.section {
            case Constants.FriendRequestsSection:
                let request = requestAtIndexPath(indexPath)
                didSelectFriendRequest(request)
            default:
                break
        }
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

        tableView!.registerClass(FriendListCell.self, forCellReuseIdentifier: FriendListCell.staticReuseIdentifier)
    }

    func installConstraints() {
        tableView.snp_makeConstraints{ make -> Void in
            make.edges.equalTo(view)
        }
    }

    func requestAtIndexPath(indexPath: NSIndexPath) -> OCTFriendRequest {
        assert(indexPath.section == Constants.FriendRequestsSection, "Wrong section used for accessing friend request")

        let normalized = NSIndexPath(forRow: indexPath.row, inSection: 0)

        return requestsFetchedController.objectAtIndexPath(normalized) as! OCTFriendRequest
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
