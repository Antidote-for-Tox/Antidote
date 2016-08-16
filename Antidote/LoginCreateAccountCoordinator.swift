//
//  LoginCreateAccountCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 20/08/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

protocol LoginCreateAccountCoordinatorDelegate: class {
    func loginCreateAccountCoordinator(coordinator: LoginCreateAccountCoordinator, 
                                       didCreateAccountWithProfileName profileName: String,
                                       username: String,
                                       password: String)
    func loginCreateAccountCoordinator(coordinator: LoginCreateAccountCoordinator,
                                       didImportProfileWithProfileName profileName: String)
    func loginCreateAccountCoordinator(coordinator: LoginCreateAccountCoordinator, didCreatePassword password: String)
}

class LoginCreateAccountCoordinator {
    enum Type {
        /// Create new account and new password.
        case CreateAccountAndPassword
        /// Import existing profile.
        case ImportProfile
        /// Create new password.
        case CreatePassword
    }

    weak var delegate: LoginCreateAccountCoordinatorDelegate?

    var userInfo = [String: Any]()

    private let theme: Theme
    private let navigationController: UINavigationController
    private let type: Type

    private var enteredUsername: String?
    private var enteredProfile: String?

    init(theme: Theme, navigationController: UINavigationController, type: Type) {
        self.theme = theme
        self.navigationController = navigationController
        self.type = type
    }
}

extension LoginCreateAccountCoordinator: CoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
        switch type {
            case .CreateAccountAndPassword:
                let controller = LoginCreateAccountController(theme: theme, type: .CreateAccount)
                controller.delegate = self
                navigationController.pushViewController(controller, animated: true)
            case .ImportProfile:
                let controller = LoginCreateAccountController(theme: theme, type: .ImportProfile)
                controller.delegate = self
                navigationController.pushViewController(controller, animated: true)
            case .CreatePassword:
                let controller = LoginCreatePasswordController(theme: theme)
                controller.delegate = self
                navigationController.pushViewController(controller, animated: true)
        }
    }
}

extension LoginCreateAccountCoordinator: LoginCreateAccountControllerDelegate {
    func loginCreateAccountControllerCreate(controller: LoginCreateAccountController, name: String, profile: String) {
        enteredUsername = name
        enteredProfile = profile

        let controller = LoginCreatePasswordController(theme: theme)
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }

    func loginCreateAccountControllerImport(controller: LoginCreateAccountController, profile: String) {
        delegate?.loginCreateAccountCoordinator(self, didImportProfileWithProfileName: profile)
    }
}

extension LoginCreateAccountCoordinator: LoginCreatePasswordControllerDelegate {
    func loginCreatePasswordController(controller: LoginCreatePasswordController, password: String) {
        switch type {
            case .CreateAccountAndPassword:
                guard let profile = enteredProfile,
                      let username = enteredUsername else {
                    fatalError("LoginCreateAccountCoordinator: unexpected state")
                }

                delegate?.loginCreateAccountCoordinator(self,
                                                        didCreateAccountWithProfileName: profile,
                                                        username: username,
                                                        password: password)
            case .ImportProfile:
                fatalError("LoginCreateAccountCoordinator: unexpected state")
            case .CreatePassword:
                delegate?.loginCreateAccountCoordinator(self, didCreatePassword: password)
        }
    }
}
