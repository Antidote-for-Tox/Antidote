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

    var userStatus: UserStatus = .Offline {
        didSet {
            navigationView.avatarView.userStatusView.userStatus = userStatus
        }
    }

    var userAvatar: UIImage? {
        didSet {
            if let image = userAvatar {
                navigationView.avatarView.imageView.image = image
            }
            else {
                navigationView.avatarView.imageView.image = UIImage.templateNamed("tab-bar-profile")
            }
        }
    }

    var userName: String? {
        didSet {
            navigationView.label.text = userName
        }
    }

    var friendsBadgeText: String? {
        didSet {
            friendsButton.badgeText = friendsBadgeText
        }
    }

    private let theme: Theme
    private weak var submanagerChats: OCTSubmanagerChats!
    private weak var submanagerObjects: OCTSubmanagerObjects!

    private var navigationView: iPadNavigationView!
    private var friendsButton: iPadFriendsButton!

    private var tableManager: ChatListTableManager!

    init(theme: Theme, submanagerChats: OCTSubmanagerChats, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme
        self.submanagerChats = submanagerChats
        self.submanagerObjects = submanagerObjects

        super.init(nibName: nil, bundle: nil)

        addNavigationButtons()

        edgesForExtendedLayout = .None
        friendsButton = iPadFriendsButton(theme: theme)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        setupButtons()
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

    func chatListTableManager(manager: ChatListTableManager, presentAlertController controller: UIAlertController) {
        presentViewController(controller, animated: true, completion: nil)
    }

    func chatListTableManagerWasUpdated(manager: ChatListTableManager) {
        // nope
    }
}

private extension PrimaryIpadController {
    func addNavigationButtons() {
        // none for now
        navigationView = iPadNavigationView(theme: theme)
        navigationView.didTapHandler = profileButtonPressed
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navigationView)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(named: "tab-bar-settings"),
                style: .Plain,
                target: self,
                action: "settingsButtonPressed")
    }

    func setupButtons() {
        friendsButton.didTapHandler = friendsButtonPressed
        view.addSubview(friendsButton)
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

    func installConstraints() {
        friendsButton.snp_makeConstraints {
            $0.top.equalTo(view)
            $0.left.right.equalTo(view)
            $0.height.equalTo(60.0)
        }

        tableManager.tableView.snp_makeConstraints {
            $0.top.equalTo(friendsButton.snp_bottom)
            $0.left.right.bottom.equalTo(view)
        }
    }
}
