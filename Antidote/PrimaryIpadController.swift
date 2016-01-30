//
//  PrimaryIpadController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 19/01/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

protocol PrimaryIpadControllerDelegate: class {
    func primaryIpadController(controller: PrimaryIpadController, didSelectChat chat: OCTChat)
    func primaryIpadControllerShowFriends(controller: PrimaryIpadController)
    func primaryIpadControllerShowSettings(controller: PrimaryIpadController)
    func primaryIpadControllerShowProfile(controller: PrimaryIpadController)
}

/**
    Controller for the iPad that is displayed as primary split controller
 */
class PrimaryIpadController: UIViewController {
    weak var delegate: PrimaryIpadControllerDelegate?

    private let theme: Theme
    private weak var submanagerObjects: OCTSubmanagerObjects!

    private var friendsButton: UIButton!
    private var settingsButton: UIButton!
    private var profileButton: UIButton!

    private var tableManager: ChatListTableManager!

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme
        self.submanagerObjects = submanagerObjects

        super.init(nibName: nil, bundle: nil)

        addNavigationButtons()

        edgesForExtendedLayout = .None
        title = String(localized: "chats_title")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        createButtons()
        createTableView()
        installConstraints()
    }
}

// MARK: Actions
extension PrimaryIpadController {
    func friendsButtonPressed() {
        delegate?.primaryIpadControllerShowFriends(self)
    }

    func settingsButtonPressed() {
        delegate?.primaryIpadControllerShowSettings(self)
    }

    func profileButtonPressed() {
        delegate?.primaryIpadControllerShowProfile(self)
    }
}

extension PrimaryIpadController: ChatListTableManagerDelegate {
    func chatListTableManager(manager: ChatListTableManager, didSelectChat chat: OCTChat) {
        delegate?.primaryIpadController(self, didSelectChat: chat)
    }
}

private extension PrimaryIpadController {
    func addNavigationButtons() {
        // none for now
    }

    func createButtons() {
        friendsButton = UIButton(type: .System)
        friendsButton.setTitle(String(localized: "friends_title"), forState: .Normal)
        friendsButton.addTarget(self, action: "friendsButtonPressed", forControlEvents: .TouchUpInside)
        view.addSubview(friendsButton)

        settingsButton = UIButton(type: .System)
        settingsButton.setTitle(String(localized: "settings_title"), forState: .Normal)
        settingsButton.addTarget(self, action: "settingsButtonPressed", forControlEvents: .TouchUpInside)
        view.addSubview(settingsButton)

        profileButton = UIButton(type: .System)
        profileButton.setTitle(String(localized: "profile_title"), forState: .Normal)
        profileButton.addTarget(self, action: "profileButtonPressed", forControlEvents: .TouchUpInside)
        view.addSubview(profileButton)
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

        tableManager = ChatListTableManager(theme: theme, tableView: tableView, submanagerObjects: submanagerObjects)
        tableManager.delegate = self
    }

    func installConstraints() {
        friendsButton.snp_makeConstraints {
            $0.top.equalTo(view)
            $0.left.right.equalTo(view)
            $0.height.equalTo(60.0)
        }

        settingsButton.snp_makeConstraints {
            $0.top.equalTo(friendsButton.snp_bottom)
            $0.left.right.equalTo(view)
            $0.height.equalTo(60.0)
        }

        profileButton.snp_makeConstraints {
            $0.top.equalTo(settingsButton.snp_bottom)
            $0.left.right.equalTo(view)
            $0.height.equalTo(60.0)
        }

        tableManager.tableView.snp_makeConstraints {
            $0.top.equalTo(profileButton.snp_bottom)
            $0.left.right.bottom.equalTo(view)
        }
    }
}
