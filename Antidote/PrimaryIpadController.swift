// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol PrimaryIpadControllerDelegate: class {
    func primaryIpadController(_ controller: PrimaryIpadController, didSelectChat chat: OCTChat)
    func primaryIpadControllerShowFriends(_ controller: PrimaryIpadController)
    func primaryIpadControllerShowSettings(_ controller: PrimaryIpadController)
    func primaryIpadControllerShowProfile(_ controller: PrimaryIpadController)
}

/**
    Controller for the iPad that is displayed as primary split controller
 */
class PrimaryIpadController: UIViewController {
    weak var delegate: PrimaryIpadControllerDelegate?

    var userStatus: UserStatus = .offline {
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

    fileprivate let theme: Theme
    fileprivate weak var submanagerChats: OCTSubmanagerChats!
    fileprivate weak var submanagerObjects: OCTSubmanagerObjects!

    fileprivate var navigationView: iPadNavigationView!
    fileprivate var friendsButton: iPadFriendsButton!

    fileprivate var tableManager: ChatListTableManager!

    init(theme: Theme, submanagerChats: OCTSubmanagerChats, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme
        self.submanagerChats = submanagerChats
        self.submanagerObjects = submanagerObjects

        super.init(nibName: nil, bundle: nil)

        addNavigationButtons()

        edgesForExtendedLayout = UIRectEdge()
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

    @objc func settingsButtonPressed() {
        delegate?.primaryIpadControllerShowSettings(self)
    }

    func profileButtonPressed() {
        delegate?.primaryIpadControllerShowProfile(self)
    }
}

extension PrimaryIpadController: ChatListTableManagerDelegate {
    func chatListTableManager(_ manager: ChatListTableManager, didSelectChat chat: OCTChat) {
        delegate?.primaryIpadController(self, didSelectChat: chat)
    }

    func chatListTableManager(_ manager: ChatListTableManager, presentAlertController controller: UIAlertController) {
        present(controller, animated: true, completion: nil)
    }

    func chatListTableManagerWasUpdated(_ manager: ChatListTableManager) {
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
                style: .plain,
                target: self,
                action: #selector(PrimaryIpadController.settingsButtonPressed))
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

        tableView.register(ChatListCell.self, forCellReuseIdentifier: ChatListCell.staticReuseIdentifier)

        tableManager = ChatListTableManager(theme: theme, tableView: tableView, submanagerChats: submanagerChats, submanagerObjects: submanagerObjects)
        tableManager.delegate = self
    }

    func installConstraints() {
        friendsButton.snp.makeConstraints {
            $0.top.equalTo(view)
            $0.leading.trailing.equalTo(view)
            $0.height.equalTo(60.0)
        }

        tableManager.tableView.snp.makeConstraints {
            $0.top.equalTo(friendsButton.snp.bottom)
            $0.leading.trailing.bottom.equalTo(view)
        }
    }
}
