// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SafariServices

private struct Options {
    static let ToShowKey = "ToShowKey"

    enum Controller {
        case advancedSettings
    }
}

protocol SettingsTabCoordinatorDelegate: class {
    func settingsTabCoordinatorRecreateCoordinatorsStack(_ coordinator: SettingsTabCoordinator, options: CoordinatorOptions)
}

class SettingsTabCoordinator: ActiveSessionNavigationCoordinator {
    weak var delegate: SettingsTabCoordinatorDelegate?

    override func startWithOptions(_ options: CoordinatorOptions?) {
        let controller = SettingsMainController(theme: theme)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: false)

        if let toShow = options?[Options.ToShowKey] as? Options.Controller {
            switch toShow {
                case .advancedSettings:
                    let advanced = SettingsAdvancedController(theme: theme)
                    advanced.delegate = self

                    navigationController.pushViewController(advanced, animated: false)
            }
        }
    }
}

extension SettingsTabCoordinator: SettingsMainControllerDelegate {
    func settingsMainControllerShowAboutScreen(_ controller: SettingsMainController) {
        let controller = SettingsAboutController(theme: theme)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: true)
    }

    func settingsMainControllerShowFaqScreen(_ controller: SettingsMainController) {
        let controller = FAQController(theme: theme)

        navigationController.pushViewController(controller, animated: true)
    }

    func settingsMainControllerChangeAutodownloadImages(_ controller: SettingsMainController) {
        let controller = ChangeAutodownloadImagesController(theme: theme)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: true)
    }

    func settingsMainControllerShowAdvancedSettings(_ controller: SettingsMainController) {
        let controller = SettingsAdvancedController(theme: theme)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: true)
    }
}

extension SettingsTabCoordinator: SettingsAboutControllerDelegate {
    func settingsAboutControllerShowAcknowledgements(_ controller: SettingsAboutController) {
        let controller = TextViewController(
                resourceName: "antidote-acknowledgements",
                backgroundColor: theme.colorForType(.NormalBackground),
                titleColor: theme.colorForType(.NormalText),
                textColor: theme.colorForType(.NormalText))
        controller.title = String(localized: "settings_acknowledgements")

        navigationController.pushViewController(controller, animated: true)
    }
}

extension SettingsTabCoordinator: ChangeAutodownloadImagesControllerDelegate {
    func changeAutodownloadImagesControllerDidChange(_ controller: ChangeAutodownloadImagesController) {
        navigationController.popViewController(animated: true)
    }
}

extension SettingsTabCoordinator: SettingsAdvancedControllerDelegate {
    func settingsAdvancedControllerToxOptionsChanged(_ controller: SettingsAdvancedController) {
        delegate?.settingsTabCoordinatorRecreateCoordinatorsStack(self, options: [
            Options.ToShowKey: Options.Controller.advancedSettings
        ])
    }
}
