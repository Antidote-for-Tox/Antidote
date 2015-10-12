//
//  LoginCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class LoginCoordinator {
    let window: UIWindow
    let navigationController: UINavigationController
    let theme: Theme

    init(window: UIWindow, theme: Theme) {
        self.window = window
        self.navigationController = UINavigationController()
        self.theme = theme
    }
}

// MARK: CoordinatorProtocol
extension LoginCoordinator : CoordinatorProtocol {
    func start() {
        let choiceVC = LoginChoiceController(theme: theme)

        navigationController.pushViewController(choiceVC, animated: false)
        window.rootViewController = navigationController
    }
}
