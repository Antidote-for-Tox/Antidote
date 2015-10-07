//
//  RunningCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class RunningCoordinator {
    let window: UIWindow
    let tabBarController: UITabBarController

    let tabCoordinators: [TabCoordinatorProtocol];

    init(window: UIWindow) {
        self.window = window
        self.tabBarController = UITabBarController()

        self.tabCoordinators = [
            FriendsTabCoordinator(),
            ChatsTabCoordinator(),
            SettingsTabCoordinator(),
            ProfileTabCoordinator(),
        ]
    }
}

// MARK: CoordinatorProtocol
extension RunningCoordinator : CoordinatorProtocol {
    func start() {
        tabCoordinators.each{ $0.start() }
        tabBarController.viewControllers = tabCoordinators.map{ $0.navigationController }

        window.rootViewController = tabBarController
    }
}
