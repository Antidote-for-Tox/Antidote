//
//  LoginCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

protocol LoginCoordinatorDelegate: class {
    func loginCoordinatorDidLogin(coordinator: LoginCoordinator)
}

class LoginCoordinator {
    var delegate: LoginCoordinatorDelegate?

    let window: UIWindow
    let navigationController: UINavigationController
    let theme: Theme

    init(window: UIWindow, theme: Theme) {
        self.window = window
        self.navigationController = PortraitNavigationController()
        self.theme = theme

        navigationController.navigationBar.tintColor = theme.colorForType(.LoginButtonText)
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

extension LoginCoordinator: LoginCreateAccountControllerDelegate {
    func loginCreateAccountControllerCreate(controller: LoginCreateAccountController, name: String, profile: String) {
        let profileManager = ProfileManager()

        if name.isEmpty || profile.isEmpty {
            UIAlertView.showWithTitle("", message: String(localized: "login_enter_username_and_profile"))
            return
        }

        if profileManager.allProfileNames.contains(profile) {
            UIAlertView.showWithTitle("", message: String(localized: "login_profile_already_exists"))
            return
        }

        do {
            try profileManager.createProfileWithName(profile)
        }
        catch let error as NSError {
            UIAlertView.showErrorWithMessage(String(localized: error.localizedDescription))
            return
        }

        let path = profileManager.pathForProfileWithName(profile)
        let configuration = OCTManagerConfiguration.configurationWithBaseDirectory(path, passphrase: nil)!
        let manager: OCTManager

        do {
            manager = try OCTManager(configuration: configuration)
        }
        catch let error as NSError {
            handleErrorWithType(.CreateOCTManager, error: error)
            _ = try? profileManager.deleteProfileWithName(profile)
            return
        }

        _ = try? manager.user.setUserName(name)
        _ = try? manager.user.setUserStatusMessage(String(localized: "default_user_status_message"))

        loginWithProfile(profile)
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
        let controller = LoginCreateAccountController(theme: theme)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: true)
    }

    func showImportProfileController() {
        let controller = TextViewController(
                resourceName: "import-profile",
                backgroundColor: theme.colorForType(.LoginBackground),
                titleColor: theme.colorForType(.LoginButtonText),
                textColor: theme.colorForType(.LoginDescriptionLabel))

        navigationController.pushViewController(controller, animated: true)
    }

    func loginWithProfile(profile: String) {
        let manager = UserDefaultsManager()
        manager.isUserLoggedIn = true
        manager.lastActiveProfile = profile

        delegate?.loginCoordinatorDidLogin(self)
    }
}
