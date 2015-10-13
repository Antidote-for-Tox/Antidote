//
//  LoginFormController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 13/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

class LoginFormController: LoginLogoController, UITextFieldDelegate {
    private struct PrivateConstants {
        static let IconContainerWidth: CGFloat = Constants.TextFieldHeight - 15.0
        static let IconContainerHeight: CGFloat = Constants.TextFieldHeight

        static let FormOffset = 20.0
        static let FormSmallOffset = 10.0
    }

    private var formView: UIView!
    private var profileFakeTextField: UITextField!
    private var profileButton: UIButton!
    private var passwordField: UITextField!

    private var loginButton: LoginButton!

    private var bottomButtonsContainer: UIView!
    private var createAccountButton: UIButton!
    private var orLabel: UILabel!
    private var importProfileButton: UIButton!

    private var profileButtonBottomToFormConstraint: Constraint!
    private var passwordFieldBottomToFormConstraint: Constraint!

    override init(theme: Theme) {
        super.init(theme: theme)
    }

    override func loadView() {
        super.loadView()

        createFormViews()
        createLoginButton()
        createBottomButtons()

        installConstraints()
    }
}

private extension LoginFormController {
    func createFormViews() {
        formView = UIView()
        formView.backgroundColor = theme.colorForType(.LoginFormBackground)
        formView.layer.cornerRadius = 5.0
        formView.layer.masksToBounds = true
        containerView.addSubview(formView)

        profileFakeTextField = UITextField()
        profileFakeTextField.borderStyle = .RoundedRect
        profileFakeTextField.leftViewMode = .Always
        profileFakeTextField.leftView = iconContainerWithImageName("login-profile-icon")
        formView.addSubview(profileFakeTextField)

        profileButton = UIButton()
        profileButton.addTarget(self, action: "profileButtonPressed", forControlEvents:.TouchUpInside)
        formView.addSubview(profileButton)

        passwordField = UITextField()
        passwordField.delegate = self
        passwordField.placeholder = String(localized:"password")
        passwordField.secureTextEntry = true
        passwordField.returnKeyType = .Go
        passwordField.borderStyle = .RoundedRect
        passwordField.leftViewMode = .Always
        passwordField.leftView = iconContainerWithImageName("login-password-icon")
        formView.addSubview(passwordField)
    }

    func createLoginButton() {
        loginButton = LoginButton(theme: theme)
        loginButton.setTitle(String(localized:"log_in"), forState: .Normal)
        loginButton.addTarget(self, action: "loginButtonPressed", forControlEvents: .TouchUpInside)
        containerView.addSubview(loginButton)
    }

    func createBottomButtons() {
        bottomButtonsContainer = UIView()
        bottomButtonsContainer.backgroundColor = .clearColor()
        containerView.addSubview(bottomButtonsContainer)

        createAccountButton = createDescriptionButtonWithTitle(
            String(localized: "create_profile"),
            action: "createAccountButtonPressed")
        bottomButtonsContainer.addSubview(createAccountButton)

        orLabel = UILabel()
        orLabel.text = String(localized: "or")
        orLabel.textColor = theme.colorForType(.LoginDescriptionLabel)
        orLabel.backgroundColor = .clearColor()
        bottomButtonsContainer.addSubview(orLabel)

        importProfileButton = createDescriptionButtonWithTitle(
                String(localized:"import_to_antidote"),
                action: "importProfileButtonPressed")
        bottomButtonsContainer.addSubview(importProfileButton)
    }

    func installConstraints() {
        formView.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(containerView)
            make.left.equalTo(containerView).offset(Constants.HorizontalOffset)
            make.right.equalTo(containerView).offset(-Constants.HorizontalOffset)
        }

        profileFakeTextField.snp_makeConstraints{ (make) -> Void in
            make.edges.equalTo(profileButton)
        }

        profileButton.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(formView).offset(PrivateConstants.FormOffset)
            make.left.equalTo(formView).offset(PrivateConstants.FormOffset)
            make.right.equalTo(formView).offset(-PrivateConstants.FormOffset)
            profileButtonBottomToFormConstraint = make.bottom.equalTo(formView).offset(-PrivateConstants.FormOffset).constraint

            make.height.equalTo(Constants.TextFieldHeight)
        }

        passwordField.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(profileButton.snp_bottom).offset(PrivateConstants.FormSmallOffset)
            make.left.right.equalTo(profileButton)
            passwordFieldBottomToFormConstraint = make.bottom.equalTo(formView).offset(-PrivateConstants.FormOffset).constraint

            make.height.equalTo(Constants.TextFieldHeight)
        }

        loginButton.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(formView.snp_bottom).offset(PrivateConstants.FormSmallOffset)
            make.left.right.equalTo(formView)
        }
    }

    func iconContainerWithImageName(imageName: String) -> UIView {
        let image = UIImage(named: imageName)!.imageWithRenderingMode(.AlwaysTemplate)

        let imageView = UIImageView(image: image)
        imageView.tintColor = UIColor(white: 200.0/255.0, alpha:1.0)

        let container = UIView()
        container.backgroundColor = .clearColor()
        container.addSubview(imageView)

        container.frame.size.width = PrivateConstants.IconContainerWidth
        container.frame.size.height = PrivateConstants.IconContainerHeight

        imageView.frame.origin.x = PrivateConstants.IconContainerWidth - imageView.frame.size.width
        imageView.frame.origin.y = (PrivateConstants.IconContainerHeight - imageView.frame.size.height) / 2 - 1.0

        return container
    }

    func createDescriptionButtonWithTitle(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(theme.colorForType(.LoginLinkColor), forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(16.0)
        button.addTarget(self, action: action, forControlEvents: .TouchUpInside)

        return button
    }
}
