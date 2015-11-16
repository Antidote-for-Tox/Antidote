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
    let tabBarController: UITabBarController

    let manager: OCTManager

    let tabCoordinators: [RunningBasicCoordinator];

    init(theme: Theme, window: UIWindow, manager: OCTManager) {
        self.window = window
        self.tabBarController = UITabBarController()
        self.manager = manager

        let friends = FriendsTabCoordinator(theme: theme)
        let chats = ChatsTabCoordinator(theme: theme)
        let settings = SettingsTabCoordinator(theme: theme)
        let profile = ProfileTabCoordinator(theme: theme)

        self.tabCoordinators = [
            friends,
            chats,
            settings,
            profile,
        ]

        super.init()

        manager.user.delegate = self
        profile.delegate = self
    }
}

extension RunningCoordinator: CoordinatorProtocol {
    func start() {
        tabCoordinators.each{ $0.start() }
        tabBarController.viewControllers = tabCoordinators.map{ $0.navigationController }

        window.rootViewController = tabBarController

        updateTabCoordinatorsWithConnecting(true)

        manager.bootstrap.addPredefinedNodes()
        manager.bootstrap.bootstrap()
    }
}

extension RunningCoordinator: OCTSubmanagerUserDelegate {
    func submanagerUser(submanager: OCTSubmanagerUser!, connectionStatusUpdate connectionStatus: OCTToxConnectionStatus) {
        updateTabCoordinatorsWithConnecting(connectionStatus == .None)
    }
}

extension RunningCoordinator: ProfileTabCoordinatorDelegate {
    func profileTabCoordinatorDelegateLogout(coordinator: ProfileTabCoordinator) {
        UserDefaultsManager().isUserLoggedIn = false

        delegate?.runningCoordinatorDidLogout(self)
    }

    func updateTabCoordinatorsWithConnecting(connecting: Bool) {
        tabCoordinators.each {
            $0.toggleConnectingStatus(show: connecting)
        }
    }
}
