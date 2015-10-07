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


    init(window: UIWindow) {
        self.window = window

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
        let isLoggedIn = true

        var coordinator: CoordinatorProtocol

        if isLoggedIn {
            coordinator = RunningCoordinator(window: window)
        }
        else {
            coordinator = LoginCoordinator(window: window)
        }

        return coordinator
    }
}

