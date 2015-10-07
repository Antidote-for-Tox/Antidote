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

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }
}

// MARK: CoordinatorProtocol
extension LoginCoordinator : CoordinatorProtocol {
    func start() {

        navigationController.pushViewController(UIViewController(), animated: false)
    }
}
