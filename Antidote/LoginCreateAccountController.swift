// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

protocol LoginCreateAccountControllerDelegate: class {
    func loginCreateAccountControllerCreate(controller: LoginCreateAccountController, name: String, profile: String)
    func loginCreateAccountControllerImport(controller: LoginCreateAccountController, profile: String)
}

class LoginCreateAccountController: LoginGenericCreateController {
    enum Type {
        case CreateAccount
        case ImportProfile
    }

    weak var delegate: LoginCreateAccountControllerDelegate?

    private let type: Type

    init(theme: Theme, type: Type) {
        self.type = type

        super.init(theme: theme)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configureViews() {
        firstTextField.title = String(localized: "create_account_username_title")
        firstTextField.placeholder = String(localized: "create_account_username_placeholder")
        firstTextField.maxTextUTF8Length = Int(kOCTToxMaxNameLength)

        secondTextField.title = String(localized: "create_account_profile_title")
        secondTextField.placeholder = String(localized: "create_account_profile_placeholder")
        secondTextField.hint = String(localized: "create_account_profile_hint")
        secondTextField.returnKeyType = .Next

        bottomButton.setTitle(String(localized: "create_account_next_button"), forState: .Normal)

        switch type {
            case .CreateAccount:
                titleLabel.text = String(localized: "create_profile")
            case .ImportProfile:
                titleLabel.text = String(localized: "import_profile")
                firstTextField.hidden = true
        }
    }

    override func bottomButtonPressed() {
        let profile = secondTextField.text ?? ""

        guard !profile.isEmpty else {
            UIAlertController.showWithTitle(String(localized: "login_enter_username_and_profile"), message: nil, retryBlock: nil)
            return
        }

        guard !ProfileManager().allProfileNames.contains(profile) else {
            UIAlertController.showWithTitle(String(localized: "login_profile_already_exists"), message: nil, retryBlock: nil)
            return
        }


        switch type {
            case .CreateAccount:
                let name = firstTextField.text ?? ""
                guard !name.isEmpty else {
                    UIAlertController.showWithTitle(String(localized: "login_enter_username_and_profile"), message: nil, retryBlock: nil)
                    return
                }

                delegate?.loginCreateAccountControllerCreate(self, name: name, profile: profile)
            case .ImportProfile:
                delegate?.loginCreateAccountControllerImport(self, profile: profile)
        }
    }
}
