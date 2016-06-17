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
    func friendListController(controller: FriendListController, showQRCodeWithText text: String)
}

class FriendListController: UIViewController {
    weak var delegate: FriendListControllerDelegate?

    private let theme: Theme

    private let dataSource: FriendListDataSource

    private weak var submanagerFriends: OCTSubmanagerFriends!
    private weak var submanagerChats: OCTSubmanagerChats!
    private weak var submanagerUser: OCTSubmanagerUser!

    private var placeholderView: UITextView!
    private var tableView: UITableView!

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects, submanagerFriends: OCTSubmanagerFriends, submanagerChats: OCTSubmanagerChats, submanagerUser: OCTSubmanagerUser) {
        self.theme = theme

        let friends = submanagerObjects.objectsForType(.Friend, predicate: nil)
        let requests = submanagerObjects.objectsForType(.FriendRequest, predicate: nil)

        self.dataSource = FriendListDataSource(theme: theme, friends: friends, requests: requests)

        self.submanagerFriends = submanagerFriends
        self.submanagerChats = submanagerChats
        self.submanagerUser = submanagerUser

        super.init(nibName: nil, bundle: nil)

        dataSource.delegate = self

        addNavigationButtons()

        edgesForExtendedLayout = .None
        title = String(localized: "contacts_title")
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
                    title = String(localized:"delete_contact_request_title")
                case .Friend:
                    title = String(localized:"delete_contact_title")
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

extension FriendListController : UITextViewDelegate {
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        if textView === placeholderView {
            let toxId = submanagerUser.userAddress
            let alert = UIAlertController(title: String(localized: "my_tox_id"), message: toxId, preferredStyle: .Alert)

            alert.addAction(UIAlertAction(title: String(localized: "copy"), style: .Default) { _ -> Void in
                UIPasteboard.generalPasteboard().string = toxId
            })

            alert.addAction(UIAlertAction(title: String(localized: "show_qr_code"), style: .Default) { [weak self] _ -> Void in
                self?.delegate?.friendListController(self!, showQRCodeWithText: toxId)
            })

            alert.addAction(UIAlertAction(title: String(localized: "alert_cancel"), style: .Cancel, handler: nil))

            presentViewController(alert, animated: true, completion: nil)
        }

        return false
    }
}

private extension FriendListController {
    func addNavigationButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .Add,
                target: self,
                action: #selector(FriendListController.addFriendButtonPressed))
    }

    func updateViewsVisibility() {
        var isEmpty = true

        for section in 0..<dataSource.numberOfSections() {
            if dataSource.numberOfRowsInSection(section) > 0 {
                isEmpty = false
                break
            }
        }

        navigationItem.leftBarButtonItem = isEmpty ? nil : editButtonItem()
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
        let top = String(localized: "contact_no_contacts_add_contact")
        let bottom = String(localized: "contact_no_contacts_share_tox_id")

        let text = NSMutableAttributedString(string: "\(top)\(bottom)")
        let linkRange = NSRange(location: top.characters.count, length: bottom.characters.count)
        let fullRange = NSRange(location: 0, length: text.length)

        text.addAttribute(NSForegroundColorAttributeName, value: theme.colorForType(.EmptyScreenPlaceholderText), range: fullRange)
        text.addAttribute(NSFontAttributeName, value: UIFont.antidoteFontWithSize(26.0, weight: .Light), range: fullRange)
        text.addAttribute(NSLinkAttributeName, value: "", range: linkRange)

        placeholderView = UITextView()
        placeholderView.delegate = self
        placeholderView.attributedText = text
        placeholderView.editable = false
        placeholderView.scrollEnabled = false
        placeholderView.textAlignment = .Center
        placeholderView.linkTextAttributes = [NSForegroundColorAttributeName : theme.colorForType(.LinkText)]
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

    func didSelectFriendRequest(request: OCTFriendRequest) {
        delegate?.friendListController(self, didSelectRequest: request)
    }
}
