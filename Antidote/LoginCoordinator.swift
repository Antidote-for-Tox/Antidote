// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

protocol LoginCoordinatorDelegate: class {
    func loginCoordinatorDidLogin(coordinator: LoginCoordinator, manager: OCTManager, password: String)
}

private enum UserInfoKey: String {
    case ImportURL
    case LoginProfile
    case LoginConfigurationClosure
    case LoginErrorClosure
}

class LoginCoordinator {
    weak var delegate: LoginCoordinatorDelegate?

    private let window: UIWindow
    private let theme: Theme
    private let navigationController: UINavigationController

    private var createAccountCoordinator: LoginCreateAccountCoordinator?

    init(theme: Theme, window: UIWindow) {
        self.window = window
        self.theme = theme

        switch InterfaceIdiom.current() {
            case .iPhone:
                self.navigationController = PortraitNavigationController()
            case .iPad:
                self.navigationController = UINavigationController()
        }

        navigationController.navigationBar.tintColor = theme.colorForType(.LoginButtonBackground)
        navigationController.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: theme.colorForType(.LoginButtonText)
        ]
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
    
    func handleLocalNotification(notification: UILocalNotification) {
        // nop
    }

    func handleInboxURL(url: NSURL) {
        guard url.isToxURL() else {
            return
        }

        guard let fileName = url.lastPathComponent else {
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
            self.importToxProfileFromURL(url)
        })

        alert.addAction(UIAlertAction(title: String(localized: "alert_cancel"), style: .Cancel, handler: nil))

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
        return isProfileEncrypted(profile)
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

extension LoginCoordinator: LoginCreateAccountCoordinatorDelegate {
    func loginCreateAccountCoordinator(coordinator: LoginCreateAccountCoordinator, 
                                       didCreateAccountWithProfileName profileName: String,
                                       username: String,
                                       password: String) {
        createProfileWithProfileName(profileName, username: username, copyFromURL: nil, password: password)
    }

    func loginCreateAccountCoordinator(coordinator: LoginCreateAccountCoordinator,
                                       didImportProfileWithProfileName profileName: String) {
        guard let url = coordinator.userInfo[UserInfoKey.ImportURL.rawValue] as? NSURL else {
            fatalError("URL should be non-nil when importing profile")
        }

        createProfileWithProfileName(profileName, username: nil, copyFromURL: url, password: nil)
    }

    func loginCreateAccountCoordinator(coordinator: LoginCreateAccountCoordinator, didCreatePassword password: String) {
        guard let profile = coordinator.userInfo[UserInfoKey.LoginProfile.rawValue] as? String else {
            fatalError("Profile should be non-nil on login")
        }

        let configurationClosure = coordinator.userInfo[UserInfoKey.LoginConfigurationClosure.rawValue] as? ((manager: OCTManager) -> Void)
        let errorClosure = coordinator.userInfo[UserInfoKey.LoginErrorClosure.rawValue] as? (NSError -> Void)

        loginWithProfile(profile, password: password, configurationClosure: configurationClosure, errorClosure: errorClosure)
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
        let coordinator = LoginCreateAccountCoordinator(theme: theme,
                                                        navigationController: navigationController,
                                                        type: .CreateAccountAndPassword)
        coordinator.delegate = self
        coordinator.startWithOptions(nil)

        createAccountCoordinator = coordinator
    }

    func showImportProfileController() {
        let controller = TextViewController(
                resourceName: "import-profile",
                backgroundColor: theme.colorForType(.LoginBackground),
                titleColor: theme.colorForType(.NormalText),
                textColor: theme.colorForType(.NormalText))

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
        guard let password = password else {
            if isProfileEncrypted(profile) {
                // Profile is encrypted, password is required. No error is needed, password placeholder
                // should be quite obvious.

                // However we should show error message for accessibility users.
                if UIAccessibilityIsVoiceOverRunning() {
                    handleErrorWithType(.PasswordIsEmpty)
                }
                return
            }

            let coordinator = LoginCreateAccountCoordinator(theme: theme,
                                                            navigationController: navigationController,
                                                            type: .CreatePassword)
            coordinator.delegate = self
            coordinator.userInfo[UserInfoKey.LoginProfile.rawValue] = profile
            coordinator.userInfo[UserInfoKey.LoginConfigurationClosure.rawValue] = configurationClosure
            coordinator.userInfo[UserInfoKey.LoginErrorClosure.rawValue] = errorClosure
            coordinator.startWithOptions(nil)

            createAccountCoordinator = coordinator
            return
        }

        let path = ProfileManager().pathForProfileWithName(profile)
        let configuration = OCTManagerConfiguration.configurationWithBaseDirectory(path)!

        let hud = JGProgressHUD(style: .Dark)
        hud.showInView(self.navigationController.view)

        ToxFactory.createToxWithConfiguration(configuration, encryptPassword: password, successBlock: { [weak self] manager -> Void in
            hud.dismiss()

            configurationClosure?(manager: manager)

            let userDefaults = UserDefaultsManager()
            userDefaults.lastActiveProfile = profile

            self?.delegate?.loginCoordinatorDidLogin(self!, manager: manager, password: password)

        }, failureBlock: { error -> Void in
            hud.dismiss()
            errorClosure?(error)
        })
    }

    func importToxProfileFromURL(url: NSURL) {
        let coordinator = LoginCreateAccountCoordinator(theme: theme,
                                                        navigationController: navigationController,
                                                        type: .ImportProfile)
        coordinator.userInfo[UserInfoKey.ImportURL.rawValue] = url
        coordinator.delegate = self
        coordinator.startWithOptions(nil)

        createAccountCoordinator = coordinator
    }

    func createProfileWithProfileName(profileName: String, username: String?, copyFromURL: NSURL?, password: String?) {
        if profileName.isEmpty {
            UIAlertController.showWithTitle("", message: String(localized: "login_enter_username_and_profile"), retryBlock: nil)
            return
        }

        let profileManager = ProfileManager()

        do {
            try profileManager.createProfileWithName(profileName, copyFromURL: copyFromURL)
        }
        catch let error as NSError {
            UIAlertController.showErrorWithMessage(String(localized: error.localizedDescription), retryBlock: nil)
            return
        }

        if isProfileEncrypted(profileName) && password == nil {
            // Cannot login without password, just opening login screen.
            UserDefaultsManager().lastActiveProfile = profileName

            let controller = self.createFormController()
            let root = self.navigationController.viewControllers[0]

            self.navigationController.setViewControllers([root, controller], animated: true)

            return
        }

        loginWithProfile(profileName, password: password, configurationClosure: {
            if let name = username {
                _ = try? $0.user.setUserName(name)
                _ = try? $0.user.setUserStatusMessage(String(localized: "default_user_status_message"))
            }
        }, errorClosure: { error in
            handleErrorWithType(.CreateOCTManager, error: error)
            _ = try? profileManager.deleteProfileWithName(profileName)
        })
    }

    func isProfileEncrypted(profile: String) -> Bool {
        let profilePath = ProfileManager().pathForProfileWithName(profile)

        let configuration = OCTManagerConfiguration.configurationWithBaseDirectory(profilePath)!
        let dataPath = configuration.fileStorage.pathForToxSaveFile

        guard NSFileManager.defaultManager().fileExistsAtPath(dataPath) else {
            return false
        }

        guard let data = NSData(contentsOfFile: dataPath) else {
            return false
        }

        return OCTToxEncryptSave.isDataEncrypted(data)
    }
}
