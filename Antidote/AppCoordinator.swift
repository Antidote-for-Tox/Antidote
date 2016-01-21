//
//  AppCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class AppCoordinator {
    private let window: UIWindow
    private var activeCoordinator: CoordinatorProtocol!
    private var theme: Theme

    private var cachedLocalNotification: UILocalNotification?

    init(window: UIWindow) {
        self.window = window

        let filepath = NSBundle.mainBundle().pathForResource("default-theme", ofType: "yaml")!
        let yamlString = try! NSString(contentsOfFile:filepath, encoding:NSUTF8StringEncoding) as String

        theme = try! Theme(yamlString: yamlString)
        applyTheme(theme)
    }

    func handleLocalNotification(notification: UILocalNotification) {
        if let running = activeCoordinator as? RunningCoordinator {
            running.handleLocalNotification(notification)
        }
        else {
            cachedLocalNotification = notification
        }
    }
}

// MARK: CoordinatorProtocol
extension AppCoordinator: CoordinatorProtocol {
    func start() {
        var coordinator: CoordinatorProtocol?

        if UserDefaultsManager().isUserLoggedIn {
            coordinator = createRunningCoordinatorWithManager(nil)
        }

        if coordinator == nil {
            coordinator = createLoginCoordinator()
        }

        activeCoordinator = coordinator
        activeCoordinator.start()

        // Trying to handle cached notification with new coordinator.
        if let notification = cachedLocalNotification {
            cachedLocalNotification = nil
            handleLocalNotification(notification)
        }
    }
}

extension AppCoordinator: RunningCoordinatorDelegate {
    func runningCoordinatorDidLogout(coordinator: RunningCoordinator) {
        start()
    }
}

extension AppCoordinator: LoginCoordinatorDelegate {
    func loginCoordinatorDidLogin(coordinator: LoginCoordinator, manager: OCTManager) {
        start()
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

    func createRunningCoordinatorWithManager(var manager: OCTManager?) -> RunningCoordinator? {
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

