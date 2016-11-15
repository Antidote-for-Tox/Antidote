// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

protocol LoginCreateAccountControllerDelegate: class {
    func loginCreateAccountControllerCreate(_ controller: LoginCreateAccountController, name: String, profile: String)
    func loginCreateAccountControllerImport(_ controller: LoginCreateAccountController, profile: String)
}

class LoginCreateAccountController: LoginGenericCreateController {
    enum ControllerType {
        case createAccount
        case importProfile
    }

    weak var delegate: LoginCreateAccountControllerDelegate?

    fileprivate let type: ControllerType

    init(theme: Theme, type: ControllerType) {
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
        secondTextField.returnKeyType = .next

        bottomButton.setTitle(String(localized: "create_account_next_button"), for: UIControlState())

        switch type {
            case .createAccount:
                titleLabel.text = String(localized: "create_profile")
            case .importProfile:
                titleLabel.text = String(localized: "import_profile")
                firstTextField.isHidden = true
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
            case .createAccount:
                let name = firstTextField.text ?? ""
                guard !name.isEmpty else {
                    UIAlertController.showWithTitle(String(localized: "login_enter_username_and_profile"), message: nil, retryBlock: nil)
                    return
                }

                delegate?.loginCreateAccountControllerCreate(self, name: name, profile: profile)
            case .importProfile:
                delegate?.loginCreateAccountControllerImport(self, profile: profile)
        }
    }
}
