//
//  AppCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class AppCoordinator {
    var window: UIWindow
    var activeCoordinator: CoordinatorProtocol!
    var theme: Theme


    init(window: UIWindow) {
        self.window = window

        let filepath = NSBundle.mainBundle().pathForResource("default-theme", ofType: "yaml")!
        let yamlString = try! NSString(contentsOfFile:filepath, encoding:NSUTF8StringEncoding) as String

        theme = try! Theme(yamlString: yamlString)
        applyTheme(theme)
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
        UIButton.appearance().tintColor = theme.colorForType(.LinkText)
        UISwitch.appearance().onTintColor = theme.colorForType(.LinkText)
    }

    func createRunningCoordinatorWithManager(var manager: OCTManager?) -> RunningCoordinator? {
        if manager == nil {
            manager =  LoginCoordinator.loginWithActiveProfile()
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

