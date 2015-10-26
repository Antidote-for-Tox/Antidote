//
//  LoginCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class LoginCoordinator {
    let window: UIWindow
    let navigationController: UINavigationController
    let theme: Theme

    init(window: UIWindow, theme: Theme) {
        self.window = window
        self.navigationController = PortraitNavigationController()
        self.theme = theme

        navigationController.navigationBar.barTintColor = theme.loginNavigationBarColor
        navigationController.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: theme.colorForType(.LoginButtonText)
        ]
    }
}

// MARK: CoordinatorProtocol
extension LoginCoordinator: CoordinatorProtocol {
    func start() {
        let profileNames = ProfileManager().allProfileNames

        let controller: UIViewController = (profileNames.count > 0) ? createFormController() : createChoiceController()

        navigationController.pushViewController(controller, animated: false)
        window.rootViewController = navigationController
    }
}

extension LoginCoordinator: LoginFormControllerDelegate {
    func loginFormControllerLogin(controller: LoginFormController, profileName: String, password: String?) {
        print("login")
    }

    func loginFormControllerCreateAccount(controller: LoginFormController) {
        showCreateAccountController()
    }

    func loginFormControllerImportProfile(controller: LoginFormController) {
        showImportProfileController()
    }

    func loginFormController(controller: LoginFormController, isProfileEncrypted profile: String) -> Bool {
        let path = ProfileManager().pathForProfileWithName(profile)

        let configuration = OCTManagerConfiguration.configurationWithBaseDirectory(path, passphrase: nil)!

        return OCTManager.isToxSaveEncryptedAtPath(configuration.fileStorage.pathForToxSaveFile)
    }
}

extension LoginCoordinator: LoginChoiceControllerDelegate {
    func loginChoiceControllerCreateAccount(controller: LoginChoiceController) {
        showCreateAccountController()
    }

    func loginChoiceControllerImportProfile(controller: LoginChoiceController) {
        showImportProfileController()
    }
}

private extension LoginCoordinator {
    func createFormController() -> LoginFormController {
        let profileNames = ProfileManager().allProfileNames
        var selectedIndex = 0

        if let activeProfile = UserDefaultsManager().lastActiveProfile {
            selectedIndex = profileNames.indexOf(activeProfile) ?? 0
        }

        let controller = LoginFormController(theme: theme, profileNames: profileNames, selectedIndex: selectedIndex)
        controller.delegate = self

        return controller
    }

    func createChoiceController() -> LoginChoiceController {
        let controller = LoginChoiceController(theme: theme)
        controller.delegate = self

        return controller
    }

    func showCreateAccountController() {
        print("create")
    }

    func showImportProfileController() {
        let controller = TextViewController(
                resourceName: "import-profile",
                backgroundColor: theme.colorForType(.LoginBackground),
                titleColor: theme.colorForType(.LoginButtonText),
                textColor: theme.colorForType(.LoginDescriptionLabel))

        navigationController.pushViewController(controller, animated: true)
    }
}
