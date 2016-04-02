//
//  AppCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

private struct Constants {
    static let ToxManagerKey = "ToxManagerKey"
}

class AppCoordinator {
    private let window: UIWindow
    private var activeCoordinator: TopCoordinatorProtocol!
    private var theme: Theme

    private var cachedLocalNotification: UILocalNotification?
    private var cachedOpenURL: OpenURL?

    init(window: UIWindow) {
        self.window = window

        let filepath = NSBundle.mainBundle().pathForResource("default-theme", ofType: "yaml")!
        let yamlString = try! NSString(contentsOfFile:filepath, encoding:NSUTF8StringEncoding) as String

        theme = try! Theme(yamlString: yamlString)
        applyTheme(theme)
    }
}

// MARK: CoordinatorProtocol
extension AppCoordinator: TopCoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
        var coordinator: TopCoordinatorProtocol?

        if UserDefaultsManager().isUserLoggedIn {
            coordinator = createRunningCoordinatorWithManager(options?[Constants.ToxManagerKey] as? OCTManager)
        }

        if coordinator == nil {
            coordinator = createLoginCoordinator()
        }

        activeCoordinator = coordinator
        activeCoordinator.startWithOptions(nil)

        // Trying to handle cached notification with new coordinator.
        if let notification = cachedLocalNotification {
            cachedLocalNotification = nil
            handleLocalNotification(notification)
        }

        // Trying to handle cached url with new coordinator.
        if let url = cachedOpenURL {
            handleOpenURL(url, resultBlock: {_ in })
        }
    }

    func handleLocalNotification(notification: UILocalNotification) -> Bool {
        if !activeCoordinator.handleLocalNotification(notification) {
            cachedLocalNotification = notification
        }

        return true
    }

    func handleOpenURL(openURL: OpenURL, resultBlock: HandleURLResult -> Void) {
        cachedOpenURL = nil

        activeCoordinator.handleOpenURL(openURL) { [weak self] result in
            switch result {
                case .Success:
                    // nop
                    break
                case .Failure(let newURL):
                    self?.cachedOpenURL = newURL
            }
        }

        resultBlock(.Success)
    }
}

extension AppCoordinator: RunningCoordinatorDelegate {
    func runningCoordinatorDidLogout(coordinator: RunningCoordinator) {
        startWithOptions(nil)
    }

    func runningCoordinatorDeleteProfile(coordinator: RunningCoordinator) {
        let userDefaults = UserDefaultsManager()
        let profileManager = ProfileManager()

        let name = userDefaults.lastActiveProfile!

        do {
            try profileManager.deleteProfileWithName(name)

            userDefaults.lastActiveProfile = nil
            startWithOptions(nil)
        }
        catch let error as NSError {
            handleErrorWithType(.DeleteProfile, error: error)
        }
    }

    func runningCoordinatorRecreateCoordinatorsStack(coordinator: RunningCoordinator, options: CoordinatorOptions) {
        activeCoordinator = createRunningCoordinatorWithManager(nil)
        activeCoordinator.startWithOptions(options)
    }
}

extension AppCoordinator: LoginCoordinatorDelegate {
    func loginCoordinatorDidLogin(coordinator: LoginCoordinator, manager: OCTManager) {
        startWithOptions([ Constants.ToxManagerKey: manager ])
    }
}

// MARK: Private
private extension AppCoordinator {
    func applyTheme(theme: Theme) {
        let linkTextColor = theme.colorForType(.LinkText)

        UIButton.appearance().tintColor = linkTextColor
        UISwitch.appearance().onTintColor = linkTextColor
        UINavigationBar.appearance().tintColor = linkTextColor
    }

    func createRunningCoordinatorWithManager(manager: OCTManager?) -> RunningCoordinator? {
        var manager = manager

        if manager == nil {
            manager = LoginCoordinator.loginWithActiveProfile()
        }

        if manager == nil {
            return nil
        }

        let coordinator = RunningCoordinator(theme: theme, window: window, toxManager: manager!)
        coordinator.delegate = self

        return coordinator
    }

    func createLoginCoordinator() -> LoginCoordinator {
        let coordinator = LoginCoordinator(theme: theme, window: window)
        coordinator.delegate = self

        return coordinator
    }
}

