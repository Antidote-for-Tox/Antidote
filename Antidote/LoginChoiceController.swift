// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

protocol LoginChoiceControllerDelegate: class {
    func loginChoiceControllerCreateAccount(controller: LoginChoiceController)
    func loginChoiceControllerImportProfile(controller: LoginChoiceController)
}

class LoginChoiceController: LoginLogoController {
    weak var delegate: LoginChoiceControllerDelegate?

    private var incompressibleContainer: IncompressibleView!
    private var createAccountButton: RoundedButton!
    private var importProfileButton: RoundedButton!

    override func loadView() {
        super.loadView()

        createContainer()
        createButtons()

        installConstraints()
    }
}

// MARK: Actions
extension LoginChoiceController {
    func createAccountButtonPressed() {
        delegate?.loginChoiceControllerCreateAccount(self)
    }

    func importProfileButtonPressed() {
        delegate?.loginChoiceControllerImportProfile(self)
    }
}

private extension LoginChoiceController {
    func createContainer() {
        incompressibleContainer = IncompressibleView()
        incompressibleContainer.backgroundColor = .clearColor()
        contentContainerView.addSubview(incompressibleContainer)
    }

    func createButtons() {
        createAccountButton = createButtonWithTitle(String(localized:"create_account"), action: #selector(LoginChoiceController.createAccountButtonPressed))
        importProfileButton = createButtonWithTitle(String(localized:"import_profile"), action: #selector(LoginChoiceController.importProfileButtonPressed))
    }

    func installConstraints() {
        incompressibleContainer.customIntrinsicContentSize.width = CGFloat(Constants.MaxFormWidth)
        incompressibleContainer.snp_makeConstraints {
            $0.top.equalTo(contentContainerView)
            $0.centerX.equalTo(contentContainerView)
            $0.width.lessThanOrEqualTo(Constants.MaxFormWidth)
            $0.width.lessThanOrEqualTo(contentContainerView).offset(-2 * Constants.HorizontalOffset)
            $0.height.equalTo(contentContainerView)
        }

        createAccountButton.snp_makeConstraints {
            $0.top.equalTo(incompressibleContainer).offset(Constants.VerticalOffset)
            $0.leading.trailing.equalTo(incompressibleContainer)
        }

        importProfileButton.snp_makeConstraints {
            $0.top.equalTo(createAccountButton.snp_bottom).offset(Constants.VerticalOffset)
            $0.leading.trailing.equalTo(incompressibleContainer)
        }
    }

    func createLabelWithText(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = theme.colorForType(.LoginDescriptionLabel)
        label.textAlignment = .Center
        label.backgroundColor = .clearColor()

        incompressibleContainer.addSubview(label)

        return label
    }

    func createButtonWithTitle(title: String, action: Selector) -> RoundedButton {
        let button = RoundedButton(theme: theme, type: .Login)
        button.setTitle(title, forState: .Normal)
        button.addTarget(self, action: action, forControlEvents: .TouchUpInside)

        incompressibleContainer.addSubview(button)

        return button
    }
}
