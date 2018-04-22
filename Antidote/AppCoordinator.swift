// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class AppCoordinator {
    fileprivate let window: UIWindow
    fileprivate var activeCoordinator: TopCoordinatorProtocol!
    fileprivate var theme: Theme

    init(window: UIWindow) {
        self.window = window

        let filepath = Bundle.main.path(forResource: "default-theme", ofType: "yaml")!
        let yamlString = try! NSString(contentsOfFile:filepath, encoding:String.Encoding.utf8.rawValue) as String

        theme = try! Theme(yamlString: yamlString)
        applyTheme(theme)
    }
}

// MARK: CoordinatorProtocol
extension AppCoordinator: TopCoordinatorProtocol {
    func startWithOptions(_ options: CoordinatorOptions?) {
        let storyboard = UIStoryboard(name: "LaunchPlaceholderBoard", bundle: Bundle.main)
        window.rootViewController = storyboard.instantiateViewController(withIdentifier: "LaunchPlaceholderController")

        recreateActiveCoordinator(options: options)
    }

    func handleLocalNotification(_ notification: UILocalNotification) {
        activeCoordinator.handleLocalNotification(notification)
    }

    func handleInboxURL(_ url: URL) {
        activeCoordinator.handleInboxURL(url)
    }
}

extension AppCoordinator: RunningCoordinatorDelegate {
    func runningCoordinatorDidLogout(_ coordinator: RunningCoordinator, importToxProfileFromURL: URL?) {
        KeychainManager().deleteActiveAccountData()

        recreateActiveCoordinator()

        if let url = importToxProfileFromURL,
           let coordinator = activeCoordinator as? LoginCoordinator {
            coordinator.handleInboxURL(url)
        }
    }

    func runningCoordinatorDeleteProfile(_ coordinator: RunningCoordinator) {
        let userDefaults = UserDefaultsManager()
        let profileManager = ProfileManager()

        let name = userDefaults.lastActiveProfile!

        do {
            try profileManager.deleteProfileWithName(name)

            KeychainManager().deleteActiveAccountData()
            userDefaults.lastActiveProfile = nil

            recreateActiveCoordinator()
        }
        catch let error as NSError {
            handleErrorWithType(.deleteProfile, error: error)
        }
    }

    func runningCoordinatorRecreateCoordinatorsStack(_ coordinator: RunningCoordinator, options: CoordinatorOptions) {
        recreateActiveCoordinator(options: options, skipAuthorizationChallenge: true)
    }
}

extension AppCoordinator: LoginCoordinatorDelegate {
    func loginCoordinatorDidLogin(_ coordinator: LoginCoordinator, manager: OCTManager, password: String) {
        KeychainManager().toxPasswordForActiveAccount = password

        recreateActiveCoordinator(manager: manager, skipAuthorizationChallenge: true)
    }
}

// MARK: Private
private extension AppCoordinator {
    func applyTheme(_ theme: Theme) {
        let linkTextColor = theme.colorForType(.LinkText)

        UIButton.appearance().tintColor = linkTextColor
        UISwitch.appearance().onTintColor = linkTextColor
        UINavigationBar.appearance().tintColor = linkTextColor
    }

    func recreateActiveCoordinator(options: CoordinatorOptions? = nil,
                                   manager: OCTManager? = nil,
                                   skipAuthorizationChallenge: Bool = false) {
        if let password = KeychainManager().toxPasswordForActiveAccount {
            let successBlock: (OCTManager) -> Void = { [unowned self] manager -> Void in
                self.activeCoordinator = self.createRunningCoordinatorWithManager(manager,
                                                                                  options: options,
                                                                                  skipAuthorizationChallenge: skipAuthorizationChallenge)
            }

            if let manager = manager {
                successBlock(manager)
            }
            else {
                let deleteActiveAccountAndRetry: () -> Void = { [unowned self] in
                    KeychainManager().deleteActiveAccountData()
                    self.recreateActiveCoordinator(options: options,
                                                   manager: manager,
                                                   skipAuthorizationChallenge: skipAuthorizationChallenge)
                }

                guard let profileName = UserDefaultsManager().lastActiveProfile else {
                    deleteActiveAccountAndRetry()
                    return
                }

                let path = ProfileManager().pathForProfileWithName(profileName)

                guard let configuration = OCTManagerConfiguration.configurationWithBaseDirectory(path) else {
                    deleteActiveAccountAndRetry()
                    return
                }

                ToxFactory.createToxWithConfiguration(configuration,
                                                      encryptPassword: password,
                                                      successBlock: successBlock,
                                                      failureBlock: { _ in
                    log("Cannot create tox with configuration \(configuration)")
                    deleteActiveAccountAndRetry()
                })
            }
        }
        else {
            activeCoordinator = createLoginCoordinator(options)
        }
    }

    func createRunningCoordinatorWithManager(_ manager: OCTManager,
                                             options: CoordinatorOptions?,
                                             skipAuthorizationChallenge: Bool) -> RunningCoordinator {
        let coordinator = RunningCoordinator(theme: theme,
                                             window: window,
                                             toxManager: manager,
                                             skipAuthorizationChallenge: skipAuthorizationChallenge)
        coordinator.delegate = self
        coordinator.startWithOptions(options)

        return coordinator
    }

    func createLoginCoordinator(_ options: CoordinatorOptions?) -> LoginCoordinator {
        let coordinator = LoginCoordinator(theme: theme, window: window)
        coordinator.delegate = self
        coordinator.startWithOptions(options)

        return coordinator
    }
}

