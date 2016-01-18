//
//  RunningCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import Cent

protocol RunningCoordinatorDelegate: class {
    func runningCoordinatorDidLogout(coordinator: RunningCoordinator)
}

class RunningCoordinator: NSObject {
    weak var delegate: RunningCoordinatorDelegate?

    let window: UIWindow
    let notificationWindow: NotificationWindow
    var tabBarController: TabBarController!

    let toxManager: OCTManager

    let tabCoordinators: [RunningNavigationCoordinator];

    var callCoordinator: CallCoordinator!

    var profileTabItem: TabBarProfileItem!

    init(theme: Theme, window: UIWindow, toxManager: OCTManager) {
        self.window = window
        self.notificationWindow = NotificationWindow(theme: theme)
        self.toxManager = toxManager

        let friends = FriendsTabCoordinator(theme: theme, toxManager: toxManager)
        let chats = ChatsTabCoordinator(theme: theme, submanagerObjects: toxManager.objects, submanagerChats: toxManager.chats)
        let settings = SettingsTabCoordinator(theme: theme)
        let profile = ProfileTabCoordinator(theme: theme, toxManager: toxManager)

        self.tabCoordinators = [
            friends,
            chats,
            settings,
            profile,
        ]

        super.init()

        tabBarController = TabBarController(theme: theme, controllersAndItems: tabCoordinators.map {
            ($0.navigationController, tabBarItemForCoordinator($0, theme: theme))
        })

        callCoordinator = CallCoordinator(
                theme: theme,
                presentingController: tabBarController,
                submanagerCalls: toxManager.calls,
                submanagerObjects: toxManager.objects)

        toxManager.user.delegate = self
        friends.delegate = self
        profile.delegate = self
    }
}

extension RunningCoordinator: CoordinatorProtocol {
    func start() {
        tabCoordinators.each{ $0.start() }
        callCoordinator.start()

        window.rootViewController = tabBarController

        let (index, _) = findTabCoordinator(ChatsTabCoordinator)!
        tabBarController.selectedIndex = index

        notificationWindow.showConnectingView(true, animated: false)

        toxManager.bootstrap.addPredefinedNodes()
        toxManager.bootstrap.bootstrap()
    }
}

extension RunningCoordinator: OCTSubmanagerUserDelegate {
    func submanagerUser(submanager: OCTSubmanagerUser!, connectionStatusUpdate connectionStatus: OCTToxConnectionStatus) {
        profileTabItem.userStatus = UserStatus(connectionStatus: connectionStatus, userStatus: submanager.userStatus)

        notificationWindow.showConnectingView(connectionStatus == .None, animated: true)
    }
}

extension RunningCoordinator: FriendsTabCoordinatorDelegate {
    func friendsTabCoordinatorOpenChat(coordinator: FriendsTabCoordinator, forFriend friend: OCTFriend) {
        let chat = toxManager.chats.getOrCreateChatWithFriend(friend)

        let (index, coordinator) = findTabCoordinator(ChatsTabCoordinator)!

        tabBarController.selectedIndex = index
        coordinator.showChat(chat, animated: false)
    }

    func friendsTabCoordinatorCall(coordinator: FriendsTabCoordinator, toFriend friend: OCTFriend) {
        let chat = toxManager.chats.getOrCreateChatWithFriend(friend)

        callCoordinator.callToChat(chat, enableVideo: false)
    }

    func friendsTabCoordinatorVideoCall(coordinator: FriendsTabCoordinator, toFriend friend: OCTFriend) {
        let chat = toxManager.chats.getOrCreateChatWithFriend(friend)

        callCoordinator.callToChat(chat, enableVideo: true)
    }
}

extension RunningCoordinator: ProfileTabCoordinatorDelegate {
    func profileTabCoordinatorDelegateLogout(coordinator: ProfileTabCoordinator) {
        UserDefaultsManager().isUserLoggedIn = false

        delegate?.runningCoordinatorDidLogout(self)
    }
}

private extension RunningCoordinator {
    func tabBarItemForCoordinator(coordinator: RunningNavigationCoordinator, theme: Theme) -> TabBarAbstractItem {
        if coordinator is FriendsTabCoordinator {
            let item = TabBarBadgeItem(theme: theme)
            item.image = UIImage(named: "tab-bar-friends")
            item.text = String(localized: "friends_title")
            return item
        }
        else if coordinator is ChatsTabCoordinator {
            let item = TabBarBadgeItem(theme: theme)
            item.image = UIImage(named: "tab-bar-chats")
            item.text = String(localized: "chats_title")
            return item
        }
        else if coordinator is SettingsTabCoordinator {
            let item = TabBarBadgeItem(theme: theme)
            item.image = UIImage(named: "tab-bar-settings")
            item.text = String(localized: "settings_title")
            return item
        }
        else if coordinator is ProfileTabCoordinator {
            profileTabItem = TabBarProfileItem(theme: theme)
            return profileTabItem
        }

        assert(false, "We shouldn't be here, something is broken")
        return TabBarAbstractItem()
    }

    func findTabCoordinator<T>(coordinator: T.Type) -> (Int, T)? {
        guard let index = tabCoordinators.findIndex({ $0 is T }) else {
            return nil
        }

        let coordinator = tabCoordinators[index] as! T
        return (index, coordinator)
    }
}
