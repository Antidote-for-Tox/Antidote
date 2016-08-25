//
//  LoginCreatePasswordController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 16/08/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

protocol LoginCreatePasswordControllerDelegate: class {
    func loginCreatePasswordController(controller: LoginCreatePasswordController, password: String)
}

class LoginCreatePasswordController: LoginGenericCreateController {
    weak var delegate: LoginCreatePasswordControllerDelegate?

    override func configureViews() {
        titleLabel.text = String(localized: "set_password_title")

        firstTextField.placeholder = String(localized: "password")
        firstTextField.secureTextEntry = true
        firstTextField.hint = String(localized: "set_password_hint")

        secondTextField.placeholder = String(localized: "repeat_password")
        secondTextField.secureTextEntry = true

        bottomButton.setTitle(String(localized: "create_account_go_button"), forState: .Normal)
    }

    override func bottomButtonPressed() {
        guard let first = firstTextField.text,
              let second = secondTextField.text else {
            handleErrorWithType(.PasswordIsEmpty)
            return
        }

        guard !first.isEmpty && !second.isEmpty else {
            handleErrorWithType(.PasswordIsEmpty)
            return
        }

        guard first == second else {
            handleErrorWithType(.PasswordsDoNotMatch)
            return
        }

        delegate?.loginCreatePasswordController(self, password: first)
    }
}
