// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol ChatListControllerDelegate: class {
    func chatListController(_ controller: ChatListController, didSelectChat chat: OCTChat)
}

class ChatListController: UIViewController {
    weak var delegate: ChatListControllerDelegate?

    fileprivate let theme: Theme
    fileprivate weak var submanagerChats: OCTSubmanagerChats!
    fileprivate weak var submanagerObjects: OCTSubmanagerObjects!

    fileprivate var placeholderLabel: UILabel!
    fileprivate var tableManager: ChatListTableManager!

    init(theme: Theme, submanagerChats: OCTSubmanagerChats, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme
        self.submanagerChats = submanagerChats
        self.submanagerObjects = submanagerObjects

        super.init(nibName: nil, bundle: nil)

        edgesForExtendedLayout = UIRectEdge()
        title = String(localized: "chats_title")
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

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        tableManager.tableView.setEditing(editing, animated: animated)
    }
}

extension ChatListController: ChatListTableManagerDelegate {
    func chatListTableManager(_ manager: ChatListTableManager, didSelectChat chat: OCTChat) {
        delegate?.chatListController(self, didSelectChat: chat)
    }

    func chatListTableManager(_ manager: ChatListTableManager, presentAlertController controller: UIAlertController) {
        present(controller, animated: true, completion: nil)
    }

    func chatListTableManagerWasUpdated(_ manager: ChatListTableManager) {
        updateViewsVisibility()
    }
}

private extension ChatListController {
    func updateViewsVisibility() {
        navigationItem.leftBarButtonItem = tableManager.isEmpty ? nil : editButtonItem
        placeholderLabel.isHidden = !tableManager.isEmpty
    }

    func createTableView() {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 44.0
        tableView.backgroundColor = theme.colorForType(.NormalBackground)
        tableView.sectionIndexColor = theme.colorForType(.LinkText)
        // removing separators on empty lines
        tableView.tableFooterView = UIView()

        view.addSubview(tableView)

        tableView.register(ChatListCell.self, forCellReuseIdentifier: ChatListCell.staticReuseIdentifier)

        tableManager = ChatListTableManager(theme: theme, tableView: tableView, submanagerChats: submanagerChats, submanagerObjects: submanagerObjects)
        tableManager.delegate = self
    }

    func createPlaceholderView() {
        placeholderLabel = UILabel()
        placeholderLabel.text = String(localized: "chat_no_chats")
        placeholderLabel.textColor = theme.colorForType(.EmptyScreenPlaceholderText)
        placeholderLabel.font = UIFont.antidoteFontWithSize(26.0, weight: .light)
        view.addSubview(placeholderLabel)
    }

    func installConstraints() {
        tableManager.tableView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }

        placeholderLabel.snp.makeConstraints {
            $0.center.equalTo(view)
            $0.size.equalTo(placeholderLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)))
        }
    }
}
