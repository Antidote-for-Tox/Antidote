// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol LoginCreateAccountCoordinatorDelegate: class {
    func loginCreateAccountCoordinator(_ coordinator: LoginCreateAccountCoordinator, 
                                       didCreateAccountWithProfileName profileName: String,
                                       username: String,
                                       password: String)
    func loginCreateAccountCoordinator(_ coordinator: LoginCreateAccountCoordinator,
                                       didImportProfileWithProfileName profileName: String)
    func loginCreateAccountCoordinator(_ coordinator: LoginCreateAccountCoordinator, didCreatePassword password: String)
}

class LoginCreateAccountCoordinator {
    enum CoordinatorType {
        /// Create new account and new password.
        case createAccountAndPassword
        /// Import existing profile.
        case importProfile
        /// Create new password.
        case createPassword
    }

    weak var delegate: LoginCreateAccountCoordinatorDelegate?

    var userInfo = [String: Any]()

    fileprivate let theme: Theme
    fileprivate let navigationController: UINavigationController
    fileprivate let type: CoordinatorType

    fileprivate var enteredUsername: String?
    fileprivate var enteredProfile: String?

    init(theme: Theme, navigationController: UINavigationController, type: CoordinatorType) {
        self.theme = theme
        self.navigationController = navigationController
        self.type = type
    }
}

extension LoginCreateAccountCoordinator: CoordinatorProtocol {
    func startWithOptions(_ options: CoordinatorOptions?) {
        switch type {
            case .createAccountAndPassword:
                let controller = LoginCreateAccountController(theme: theme, type: .createAccount)
                controller.delegate = self
                navigationController.pushViewController(controller, animated: true)
            case .importProfile:
                let controller = LoginCreateAccountController(theme: theme, type: .importProfile)
                controller.delegate = self
                navigationController.pushViewController(controller, animated: true)
            case .createPassword:
                let controller = LoginCreatePasswordController(theme: theme)
                controller.delegate = self
                navigationController.pushViewController(controller, animated: true)
        }
    }
}

extension LoginCreateAccountCoordinator: LoginCreateAccountControllerDelegate {
    func loginCreateAccountControllerCreate(_ controller: LoginCreateAccountController, name: String, profile: String) {
        enteredUsername = name
        enteredProfile = profile

        let controller = LoginCreatePasswordController(theme: theme)
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }

    func loginCreateAccountControllerImport(_ controller: LoginCreateAccountController, profile: String) {
        delegate?.loginCreateAccountCoordinator(self, didImportProfileWithProfileName: profile)
    }
}

extension LoginCreateAccountCoordinator: LoginCreatePasswordControllerDelegate {
    func loginCreatePasswordController(_ controller: LoginCreatePasswordController, password: String) {
        switch type {
            case .createAccountAndPassword:
                guard let profile = enteredProfile,
                      let username = enteredUsername else {
                    fatalError("LoginCreateAccountCoordinator: unexpected state")
                }

                delegate?.loginCreateAccountCoordinator(self,
                                                        didCreateAccountWithProfileName: profile,
                                                        username: username,
                                                        password: password)
            case .importProfile:
                fatalError("LoginCreateAccountCoordinator: unexpected state")
            case .createPassword:
                delegate?.loginCreateAccountCoordinator(self, didCreatePassword: password)
        }
    }
}
