//
//  LoginChoiceController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 10/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

protocol LoginChoiceControllerDelegate: class {
    func loginChoiceControllerCreateAccount(controller: LoginChoiceController)
    func loginChoiceControllerImportProfile(controller: LoginChoiceController)
}

class LoginChoiceController: LoginLogoController {
    weak var delegate: LoginChoiceControllerDelegate?

    private var welcomeLabel: UILabel!
    private var createAccountButton: LoginButton!
    private var orLabel: UILabel!
    private var importProfileButton: LoginButton!

    override func loadView() {
        super.loadView()

        createLabels()
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
    func createLabels() {
        welcomeLabel = createLabelWithText(String(localized:"login_welcome_text"))
        orLabel = createLabelWithText(String(localized:"or"))
    }

    func createButtons() {
        createAccountButton = createButtonWithTitle(String(localized:"create_account"), action: "createAccountButtonPressed")
        importProfileButton = createButtonWithTitle(String(localized:"import_profile"), action: "importProfileButtonPressed")
    }

    func installConstraints() {
        welcomeLabel.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(contentContainerView)
            make.left.equalTo(contentContainerView).offset(Constants.HorizontalOffset)
            make.right.equalTo(contentContainerView).offset(-Constants.HorizontalOffset)
        }

        createAccountButton.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(welcomeLabel.snp_bottom).offset(Constants.VerticalOffset)
            make.left.right.equalTo(welcomeLabel)
        }

        orLabel.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(createAccountButton.snp_bottom).offset(Constants.SmallVerticalOffset)
            make.left.right.equalTo(welcomeLabel)
        }

        importProfileButton.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(orLabel.snp_bottom).offset(Constants.SmallVerticalOffset)
            make.left.right.equalTo(welcomeLabel)
        }
    }

    func createLabelWithText(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = theme.colorForType(.LoginDescriptionLabel)
        label.textAlignment = .Center
        label.backgroundColor = .clearColor()

        contentContainerView.addSubview(label)

        return label
    }

    func createButtonWithTitle(title: String, action: Selector) -> LoginButton {
        let button = LoginButton(theme: theme)
        button.setTitle(title, forState: .Normal)
        button.addTarget(self, action: action, forControlEvents: .TouchUpInside)

        contentContainerView.addSubview(button)

        return button
    }
}
