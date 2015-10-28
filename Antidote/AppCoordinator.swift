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

        self.theme = try! Theme(yamlString: yamlString)
    }
}

// MARK: CoordinatorProtocol
extension AppCoordinator: CoordinatorProtocol {
    func start() {
        activeCoordinator = createActualCoordinator()
        activeCoordinator.start()
    }
}

extension AppCoordinator: LoginCoordinatorDelegate {
    func loginCoordinatorDidLogin(coordinator: LoginCoordinator) {
        start()
    }
}

// MARK: Private
private extension AppCoordinator {
    func createActualCoordinator() -> CoordinatorProtocol {
        let userDefaults = UserDefaultsManager()

        if userDefaults.isUserLoggedIn && (userDefaults.lastActiveProfile != nil) {
            let coordinator = RunningCoordinator(window: window)

            return coordinator
        }
        else {
            let coordinator = LoginCoordinator(window: window, theme: theme)
            coordinator.delegate = self

            return coordinator
        }
    }
}

