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
    let tabBarController: UITabBarController

    let toxManager: OCTManager

    let tabCoordinators: [RunningBasicCoordinator];

    var callCoordinator: CallCoordinator

    init(theme: Theme, window: UIWindow, toxManager: OCTManager) {
        self.window = window
        self.notificationWindow = NotificationWindow(theme: theme)
        self.tabBarController = UITabBarController()
        self.toxManager = toxManager

        let friends = FriendsTabCoordinator(theme: theme, toxManager: toxManager)
        let chats = ChatsTabCoordinator(theme: theme)
        let settings = SettingsTabCoordinator(theme: theme)
        let profile = ProfileTabCoordinator(theme: theme, toxManager: toxManager)

        self.tabCoordinators = [
            friends,
            chats,
            settings,
            profile,
        ]

        self.callCoordinator = CallCoordinator(
                theme: theme,
                presentingController: tabBarController,
                submanagerCalls: toxManager.calls,
                submanagerObjects: toxManager.objects)

        super.init()

        toxManager.user.delegate = self
        friends.delegate = self
        profile.delegate = self
    }
}

extension RunningCoordinator: CoordinatorProtocol {
    func start() {
        tabCoordinators.each{ $0.start() }
        callCoordinator.start()

        tabBarController.viewControllers = tabCoordinators.map{ $0.navigationController }

        window.rootViewController = tabBarController

        notificationWindow.showConnectingView(true, animated: false)

        toxManager.bootstrap.addPredefinedNodes()
        toxManager.bootstrap.bootstrap()
    }
}

extension RunningCoordinator: OCTSubmanagerUserDelegate {
    func submanagerUser(submanager: OCTSubmanagerUser!, connectionStatusUpdate connectionStatus: OCTToxConnectionStatus) {
        notificationWindow.showConnectingView(connectionStatus == .None, animated: true)
    }
}

extension RunningCoordinator: FriendsTabCoordinatorDelegate {
    func friendsTabCoordinatorOpenChat(coordinator: FriendsTabCoordinator, forFriend friend: OCTFriend) {
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
