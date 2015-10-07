//
//  SettingsTabCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class SettingsTabCoordinator {
    let navigationController = UINavigationController()
}

// MARK: CoordinatorProtocol
extension SettingsTabCoordinator : TabCoordinatorProtocol {
    func start() {
        let controller = UIViewController()
        controller.title = "Settings"

        navigationController.pushViewController(controller, animated: false)
    }
}
