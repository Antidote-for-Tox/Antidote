//
//  LoginCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

protocol LoginCoordinatorDelegate: class {
    func loginCoordinatorDidLogin(coordinator: LoginCoordinator, manager: OCTManager)
}

class LoginCoordinator {
    weak var delegate: LoginCoordinatorDelegate?

    let window: UIWindow
    let navigationController: UINavigationController
    let theme: Theme

    init(theme: Theme, window: UIWindow) {
        self.window = window
        self.theme = theme

        switch InterfaceIdiom.current() {
            case .iPhone:
                self.navigationController = PortraitNavigationController()
            case .iPad:
                self.navigationController = UINavigationController()
        }

        navigationController.navigationBar.tintColor = theme.colorForType(.LoginButtonText)
        navigationController.navigationBar.barTintColor = theme.loginNavigationBarColor
        navigationController.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: theme.colorForType(.LoginButtonText)
        ]
    }

    /**
     * Tries to login with active profile. Returns nil
     * - if there is no active profile.
     * - if profile is encrypted.
     * - if there was some error during login.
     */
    class func loginWithActiveProfile() -> OCTManager? {
        guard let profile = UserDefaultsManager().lastActiveProfile else {
            return nil
        }

        return try? createOCTManagerWithProfile(profile, password: nil)
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
        loginWithProfile(profileName, password: password)
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

        loginWithProfile(profile, password: nil, configurationClosure:{
            _ = try? $0.user.setUserName(name)
            _ = try? $0.user.setUserStatusMessage(String(localized: "default_user_status_message"))
        }, errorClosure:{
            _ = try? profileManager.deleteProfileWithName(profile)
        })
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

    /**
     * @param profile The name of profile.
     * @param password Password to decrypt profile.
     * @param configurationClosure Closure called after login to configure profile.
     * @param errorClosure Closure called if any error occured during login.
     */
    func loginWithProfile(
            profile: String,
            password: String?,
            configurationClosure: ((manager: OCTManager) -> Void)? = nil,
            errorClosure: (() -> Void)? = nil)
    {
        let manager: OCTManager

        do {
            manager = try LoginCoordinator.createOCTManagerWithProfile(profile, password: password)
        }
        catch let error as NSError {
            handleErrorWithType(.CreateOCTManager, error: error)
            errorClosure?()
            return
        }

        configurationClosure?(manager: manager)

        let userDefaults = UserDefaultsManager()
        userDefaults.isUserLoggedIn = true
        userDefaults.lastActiveProfile = profile

        delegate?.loginCoordinatorDidLogin(self, manager: manager)
    }

    class func createOCTManagerWithProfile(profile: String, password: String?) throws -> OCTManager {
        let path = ProfileManager().pathForProfileWithName(profile)
        let configuration = OCTManagerConfiguration.configurationWithBaseDirectory(path, passphrase: nil)!

        return try OCTManager(configuration: configuration)
    }
}
