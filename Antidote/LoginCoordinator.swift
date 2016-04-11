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
    let theme: Theme
    let navigationController: UINavigationController

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

// MARK: TopCoordinatorProtocol
extension LoginCoordinator: TopCoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
        let profileNames = ProfileManager().allProfileNames

        let controller: UIViewController = (profileNames.count > 0) ? createFormController() : createChoiceController()

        navigationController.pushViewController(controller, animated: false)
        window.rootViewController = navigationController
    }

    func handleOpenURL(openURL: OpenURL, resultBlock: HandleURLResult -> Void) {
        guard openURL.url.isToxURL() else {
            resultBlock(.DidNotHandle(openURL: openURL))
            return
        }

        guard let fileName = openURL.url.lastPathComponent else {
            resultBlock(.DidNotHandle(openURL: openURL))
            return
        }

        if !openURL.askUser {
            resultBlock(.DidHandle)
            self.importToxProfileFromURL(openURL.url)
            return
        }

        let style: UIAlertControllerStyle

        switch InterfaceIdiom.current() {
            case .iPhone:
                style = .ActionSheet
            case .iPad:
                style = .Alert
        }

        let alert = UIAlertController(title: nil, message: fileName, preferredStyle: style)

        alert.addAction(UIAlertAction(title: String(localized: "create_profile"), style: .Default) { [unowned self] _ -> Void in
            resultBlock(.DidHandle)
            self.importToxProfileFromURL(openURL.url)
        })

        alert.addAction(UIAlertAction(title: String(localized: "alert_cancel"), style: .Cancel) { _ -> Void in
            resultBlock(.DidNotHandle(openURL: openURL))
        })

        navigationController.presentViewController(alert, animated: true, completion: nil)
    }
}

extension LoginCoordinator: LoginFormControllerDelegate {
    func loginFormControllerLogin(controller: LoginFormController, profileName: String, password: String?) {
        loginWithProfile(profileName, password: password, errorClosure: { error in
            handleErrorWithType(.CreateOCTManager, error: error)
        })
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
        if name.isEmpty {
            UIAlertController.showWithTitle("", message: String(localized: "login_enter_username_and_profile"), retryBlock: nil)
            return
        }

        createProfileWithProfileName(profile, username: name, copyFromURL: nil, allowEncrypted: false)
    }

    func loginCreateAccountControllerImport(controller: LoginCreateAccountController, profile: String, userInfo: AnyObject?) {
        let url = userInfo as! NSURL

        createProfileWithProfileName(profile, username: nil, copyFromURL: url, allowEncrypted: true)
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
        let controller = LoginCreateAccountController(theme: theme, type: .CreateAccount)
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
            errorClosure: (NSError -> Void)? = nil)
    {
        let manager: OCTManager

        do {
            manager = try LoginCoordinator.createOCTManagerWithProfile(profile, password: password)
        }
        catch let error as NSError {
            errorClosure?(error)
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

        let configuration = OCTManagerConfiguration.configurationWithBaseDirectory(path, passphrase: password)!

        return try OCTManager(configuration: configuration)
    }

    func importToxProfileFromURL(url: NSURL) {
        let controller = LoginCreateAccountController(theme: theme, type: .ImportProfile(userInfo: url))
        controller.delegate = self
        let root = navigationController.viewControllers[0]

        navigationController.setViewControllers([root, controller], animated: true)
    }

    func createProfileWithProfileName(profileName: String, username: String?, copyFromURL: NSURL?, allowEncrypted: Bool) {
        if profileName.isEmpty {
            UIAlertController.showWithTitle("", message: String(localized: "login_enter_username_and_profile"), retryBlock: nil)
            return
        }

        let profileManager = ProfileManager()

        if profileManager.allProfileNames.contains(profileName) {
            UIAlertController.showWithTitle("", message: String(localized: "login_profile_already_exists"), retryBlock: nil)
            return
        }

        do {
            try profileManager.createProfileWithName(profileName, copyFromURL: copyFromURL)
        }
        catch let error as NSError {
            UIAlertController.showErrorWithMessage(String(localized: error.localizedDescription), retryBlock: nil)
            return
        }

        loginWithProfile(profileName, password: nil, configurationClosure: {
            if let name = username {
                _ = try? $0.user.setUserName(name)
                _ = try? $0.user.setUserStatusMessage(String(localized: "default_user_status_message"))
            }
        }, errorClosure: { [unowned self] error in
            let code = OCTManagerInitError(rawValue: error.code)

            if allowEncrypted && code == .CreateToxEncrypted {
                UserDefaultsManager().lastActiveProfile = profileName

                let controller = self.createFormController()
                let root = self.navigationController.viewControllers[0]

                self.navigationController.setViewControllers([root, controller], animated: true)
            }
            else {
                handleErrorWithType(.CreateOCTManager, error: error)
                _ = try? profileManager.deleteProfileWithName(profileName)
            }
        })
    }
}
