// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

protocol LoginChoiceControllerDelegate: class {
    func loginChoiceControllerCreateAccount(_ controller: LoginChoiceController)
    func loginChoiceControllerImportProfile(_ controller: LoginChoiceController)
}

class LoginChoiceController: LoginLogoController {
    weak var delegate: LoginChoiceControllerDelegate?

    fileprivate var incompressibleContainer: IncompressibleView!
    fileprivate var createAccountButton: RoundedButton!
    fileprivate var importProfileButton: RoundedButton!

    override func loadView() {
        super.loadView()

        createContainer()
        createButtons()

        installConstraints()
    }
}

// MARK: Actions
extension LoginChoiceController {
    @objc func createAccountButtonPressed() {
        delegate?.loginChoiceControllerCreateAccount(self)
    }

    @objc func importProfileButtonPressed() {
        delegate?.loginChoiceControllerImportProfile(self)
    }
}

private extension LoginChoiceController {
    func createContainer() {
        incompressibleContainer = IncompressibleView()
        incompressibleContainer.backgroundColor = .clear
        contentContainerView.addSubview(incompressibleContainer)
    }

    func createButtons() {
        createAccountButton = createButtonWithTitle(String(localized:"create_account"), action: #selector(LoginChoiceController.createAccountButtonPressed))
        importProfileButton = createButtonWithTitle(String(localized:"import_profile"), action: #selector(LoginChoiceController.importProfileButtonPressed))
    }

    func installConstraints() {
        incompressibleContainer.customIntrinsicContentSize.width = CGFloat(Constants.MaxFormWidth)
        incompressibleContainer.snp.makeConstraints {
            $0.top.equalTo(contentContainerView)
            $0.centerX.equalTo(contentContainerView)
            $0.width.lessThanOrEqualTo(Constants.MaxFormWidth)
            $0.width.lessThanOrEqualTo(contentContainerView).offset(-2 * Constants.HorizontalOffset)
            $0.height.equalTo(contentContainerView)
        }

        createAccountButton.snp.makeConstraints {
            $0.top.equalTo(incompressibleContainer).offset(Constants.VerticalOffset)
            $0.leading.trailing.equalTo(incompressibleContainer)
        }

        importProfileButton.snp.makeConstraints {
            $0.top.equalTo(createAccountButton.snp.bottom).offset(Constants.VerticalOffset)
            $0.leading.trailing.equalTo(incompressibleContainer)
        }
    }

    func createLabelWithText(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = theme.colorForType(.LoginDescriptionLabel)
        label.textAlignment = .center
        label.backgroundColor = .clear

        incompressibleContainer.addSubview(label)

        return label
    }

    func createButtonWithTitle(_ title: String, action: Selector) -> RoundedButton {
        let button = RoundedButton(theme: theme, type: .login)
        button.setTitle(title, for: UIControlState())
        button.addTarget(self, action: action, for: .touchUpInside)

        incompressibleContainer.addSubview(button)

        return button
    }
}
