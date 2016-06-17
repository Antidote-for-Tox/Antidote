//
//  FriendSelectController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 11.04.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

protocol FriendSelectControllerDelegate: class {
    func friendSelectController(controller: FriendSelectController, didSelectFriend friend: OCTFriend)
    func friendSelectControllerCancel(controller: FriendSelectController)
}

class FriendSelectController: UIViewController {
    weak var delegate: FriendSelectControllerDelegate?

    var userInfo: AnyObject?

    private let theme: Theme

    private let dataSource: FriendListDataSource

    private var placeholderView: UITextView!
    private var tableView: UITableView!

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects, userInfo: AnyObject? = nil) {
        self.theme = theme
        self.userInfo = userInfo

        let friends = submanagerObjects.objectsForType(.Friend, predicate: nil)
        self.dataSource = FriendListDataSource(theme: theme, friends: friends)

        super.init(nibName: nil, bundle: nil)

        dataSource.delegate = self

        addNavigationButtons()

        edgesForExtendedLayout = .None
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        createTableView()
        createPlaceholderView()
        installConstraints()

        updateViewsVisibility()
    }
}

extension FriendSelectController {
    func cancelButtonPressed() {
        delegate?.friendSelectControllerCancel(self)
    }
}

extension FriendSelectController: FriendListDataSourceDelegate {
    func friendListDataSourceBeginUpdates() {
        tableView.beginUpdates()
    }

    func friendListDataSourceEndUpdates() {
        self.tableView.endUpdates()
        updateViewsVisibility()
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

extension FriendSelectController: UITableViewDataSource {
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

extension FriendSelectController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        switch dataSource.objectAtIndexPath(indexPath) {
            case .Request:
                // nop
                break
            case .Friend(let friend):
                delegate?.friendSelectController(self, didSelectFriend: friend)
        }
    }
}

private extension FriendSelectController {
    func addNavigationButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .Cancel,
                target: self,
                action: #selector(FriendSelectController.cancelButtonPressed))
    }

    func updateViewsVisibility() {
        var isEmpty = true

        for section in 0..<dataSource.numberOfSections() {
            if dataSource.numberOfRowsInSection(section) > 0 {
                isEmpty = false
                break
            }
        }

        placeholderView.hidden = !isEmpty
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

    func createPlaceholderView() {
        placeholderView = UITextView()
        placeholderView.text = String(localized: "contact_no_contacts")
        placeholderView.editable = false
        placeholderView.scrollEnabled = false
        placeholderView.textAlignment = .Center
        view.addSubview(placeholderView)
    }

    func installConstraints() {
        tableView.snp_makeConstraints {
            $0.edges.equalTo(view)
        }

        placeholderView.snp_makeConstraints {
            $0.center.equalTo(view)
            $0.size.equalTo(placeholderView.sizeThatFits(CGSize(width: CGFloat.max, height: CGFloat.max)))
        }
    }
}
