//
//  SettingsTabCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class SettingsTabCoordinator: RunningNavigationCoordinator {
    override func start() {
        let controller = SettingsMainController(theme: theme)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: false)
    }
}

extension SettingsTabCoordinator: SettingsMainControllerDelegate {
    func settingsMainControllerShowAboutScreen(controller: SettingsMainController) {
        let controller = SettingsAboutController(theme: theme)

        navigationController.pushViewController(controller, animated: true)
    }

    func settingsMainControllerShowBetaTesterMenu(controller: SettingsMainController) {
        let controller = BetaTestersMenuController()

        navigationController.pushViewController(controller, animated: true)
    }

    func settingsMainControllerShowAdvancedSettings(controller: SettingsMainController) {
        let controller = SettingsAdvancedController(theme: theme)

        navigationController.pushViewController(controller, animated: true)
    }
}
