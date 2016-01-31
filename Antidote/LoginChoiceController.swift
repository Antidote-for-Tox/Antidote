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

    private var incompressibleContainer: IncompressibleView!
    private var welcomeLabel: UILabel!
    private var createAccountButton: RoundedButton!
    private var orLabel: UILabel!
    private var importProfileButton: RoundedButton!

    override func loadView() {
        super.loadView()

        createContainer()
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
    func createContainer() {
        incompressibleContainer = IncompressibleView()
        incompressibleContainer.backgroundColor = .clearColor()
        contentContainerView.addSubview(incompressibleContainer)
    }

    func createLabels() {
        welcomeLabel = createLabelWithText(String(localized:"login_welcome_text"))
        orLabel = createLabelWithText(String(localized:"login_or_label"))
    }

    func createButtons() {
        createAccountButton = createButtonWithTitle(String(localized:"create_account"), action: "createAccountButtonPressed")
        importProfileButton = createButtonWithTitle(String(localized:"import_profile"), action: "importProfileButtonPressed")
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

        welcomeLabel.snp_makeConstraints {
            $0.top.equalTo(incompressibleContainer)
            $0.left.right.equalTo(incompressibleContainer)
        }

        createAccountButton.snp_makeConstraints {
            $0.top.equalTo(welcomeLabel.snp_bottom).offset(Constants.VerticalOffset)
            $0.left.right.equalTo(welcomeLabel)
        }

        orLabel.snp_makeConstraints {
            $0.top.equalTo(createAccountButton.snp_bottom).offset(Constants.SmallVerticalOffset)
            $0.left.right.equalTo(welcomeLabel)
        }

        importProfileButton.snp_makeConstraints {
            $0.top.equalTo(orLabel.snp_bottom).offset(Constants.SmallVerticalOffset)
            $0.left.right.equalTo(welcomeLabel)
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
