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

        activeCoordinator = createActualCoordinator()
    }
}

// MARK: CoordinatorProtocol
extension AppCoordinator : CoordinatorProtocol {
    func start() {
        activeCoordinator.start()
    }
}

// MARK: Private
private extension AppCoordinator {
    func createActualCoordinator() -> CoordinatorProtocol {
        let userDefaults = UserDefaultsManager()
        var coordinator: CoordinatorProtocol

        if userDefaults.isUserLoggedIn && (userDefaults.lastActiveProfile != nil) {
            coordinator = RunningCoordinator(window: window)
        }
        else {
            coordinator = LoginCoordinator(window: window, theme: theme)
        }

        return coordinator
    }
}

