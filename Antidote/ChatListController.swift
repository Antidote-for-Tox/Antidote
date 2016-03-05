//
//  ChatListController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 12/01/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

protocol ChatListControllerDelegate: class {
    func chatListController(controller: ChatListController, didSelectChat chat: OCTChat)
}

class ChatListController: UIViewController {
    weak var delegate: ChatListControllerDelegate?

    private let theme: Theme
    private weak var submanagerChats: OCTSubmanagerChats!
    private weak var submanagerObjects: OCTSubmanagerObjects!

    private var placeholderLabel: UILabel!
    private var tableManager: ChatListTableManager!

    init(theme: Theme, submanagerChats: OCTSubmanagerChats, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme
        self.submanagerChats = submanagerChats
        self.submanagerObjects = submanagerObjects

        super.init(nibName: nil, bundle: nil)

        edgesForExtendedLayout = .None
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

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        tableManager.tableView.setEditing(editing, animated: animated)
    }
}

extension ChatListController: ChatListTableManagerDelegate {
    func chatListTableManager(manager: ChatListTableManager, didSelectChat chat: OCTChat) {
        delegate?.chatListController(self, didSelectChat: chat)
    }

    func chatListTableManager(manager: ChatListTableManager, presentAlertController controller: UIAlertController) {
        presentViewController(controller, animated: true, completion: nil)
    }

    func chatListTableManagerWasUpdated(manager: ChatListTableManager) {
        updateViewsVisibility()
    }
}

private extension ChatListController {
    func updateViewsVisibility() {
        navigationItem.leftBarButtonItem = tableManager.isEmpty ? nil : editButtonItem()
        placeholderLabel.hidden = !tableManager.isEmpty
    }

    func createTableView() {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 44.0
        tableView.backgroundColor = theme.colorForType(.NormalBackground)
        tableView.sectionIndexColor = theme.colorForType(.LinkText)
        // removing separators on empty lines
        tableView.tableFooterView = UIView()

        view.addSubview(tableView)

        tableView.registerClass(ChatListCell.self, forCellReuseIdentifier: ChatListCell.staticReuseIdentifier)

        tableManager = ChatListTableManager(theme: theme, tableView: tableView, submanagerChats: submanagerChats, submanagerObjects: submanagerObjects)
        tableManager.delegate = self
    }

    func createPlaceholderView() {
        placeholderLabel = UILabel()
        placeholderLabel.text = String(localized: "chat_no_chats")
        placeholderLabel.textColor = theme.colorForType(.EmptyScreenPlaceholderText)
        placeholderLabel.font = UIFont.systemFontOfSize(26.0, weight: UIFontWeightLight)
        view.addSubview(placeholderLabel)
    }

    func installConstraints() {
        tableManager.tableView.snp_makeConstraints {
            $0.edges.equalTo(view)
        }

        placeholderLabel.snp_makeConstraints {
            $0.center.equalTo(view)
            $0.size.equalTo(placeholderLabel.sizeThatFits(CGSize(width: CGFloat.max, height: CGFloat.max)))
        }
    }
}
