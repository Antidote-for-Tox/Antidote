// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
