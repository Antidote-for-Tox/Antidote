//
//  LoginCreateAccountController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 27/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct PrivateConstants {
    static let FieldsOffset = 20.0
    static let VerticalOffset = 30.0
    static let HorizontalOffset = 40.0
}

protocol LoginCreateAccountControllerDelegate: class {
    func loginCreateAccountControllerCreate(controller: LoginCreateAccountController, name: String, profile: String)
}

class LoginCreateAccountController: LoginBaseController {
    weak var delegate: LoginCreateAccountControllerDelegate?

    private var containerView: UIView!
    private var containerViewTopConstraint: Constraint!

    private var titleLabel: UILabel!
    private var usernameView: LoginExtendedTextField!
    private var profileView: LoginExtendedTextField!
    private var goButton: LoginButton!

    override func loadView() {
        super.loadView()

        createGestureRecognizers()
        createContainerView()
        createTitleLabel()
        createExtendedTextFields()
        createGoButton()

        installConstraints()
    }

    override func keyboardWillShowAnimated(keyboardFrame frame: CGRect) {
        let underFormHeight = containerView.frame.size.height - CGRectGetMaxY(profileView.frame)

        let offset = min(0.0, underFormHeight - frame.height)

        containerViewTopConstraint.updateOffset(offset)
        view.layoutIfNeeded()
    }

    override func keyboardWillHideAnimated(keyboardFrame frame: CGRect) {
        containerViewTopConstraint.updateOffset(0.0)
        view.layoutIfNeeded()
    }
}

// MARK: Actions
extension LoginCreateAccountController {
    func tapOnView() {
        view.endEditing(true)
    }

    func goButtonPressed() {
        let name = usernameView.text ?? ""
        let profile = profileView.text ?? ""

        delegate?.loginCreateAccountControllerCreate(self, name: name, profile: profile)
    }
}

extension LoginCreateAccountController: LoginExtendedTextFieldDelegate {
    func loginExtendedTextFieldReturnKeyPressed(field: LoginExtendedTextField) {
        if field == usernameView {
            profileView.becomeFirstResponder()
        }
        else if field == profileView {
            profileView.resignFirstResponder()
            goButtonPressed()
        }
    }
}

private extension LoginCreateAccountController {
    func createGestureRecognizers() {
        let tapGR = UITapGestureRecognizer(target: self, action: "tapOnView")
        view.addGestureRecognizer(tapGR)
    }

    func createContainerView() {
        containerView = UIView()
        containerView.backgroundColor = .clearColor()
        view.addSubview(containerView)
    }

    func createTitleLabel() {
        titleLabel = UILabel()
        titleLabel.text = String(localized: "create_profile")
        titleLabel.textColor = theme.colorForType(.LoginButtonText)
        titleLabel.font = UIFont.systemFontOfSize(26.0, weight: UIFontWeightLight)
        titleLabel.backgroundColor = .clearColor()
        containerView.addSubview(titleLabel)
    }

    func createExtendedTextFields() {
        usernameView = LoginExtendedTextField(theme: theme)
        usernameView.delegate = self
        usernameView.title = String(localized: "create_account_username_title")
        usernameView.placeholder = String(localized: "create_account_username_placeholder")
        usernameView.returnKeyType = .Next
        usernameView.maxTextUTF8Length = Int(kOCTToxMaxNameLength)
        containerView.addSubview(usernameView)

        profileView = LoginExtendedTextField(theme: theme)
        profileView.delegate = self
        profileView.title = String(localized: "create_account_profile_title")
        profileView.placeholder = String(localized: "create_account_profile_placeholder")
        profileView.hint = String(localized: "create_account_profile_hint")
        profileView.returnKeyType = .Go
        containerView.addSubview(profileView)
    }

    func createGoButton() {
        goButton = LoginButton(theme: theme)
        goButton.setTitle(String(localized: "create_account_go_button"), forState: .Normal)
        goButton.addTarget(self, action: "goButtonPressed", forControlEvents: .TouchUpInside)
        containerView.addSubview(goButton)
    }

    func installConstraints() {
        containerView.snp_makeConstraints{ (make) -> Void in
            containerViewTopConstraint = make.top.equalTo(view).constraint
            make.left.right.equalTo(view)
            make.height.equalTo(view)
        }

        titleLabel.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(containerView).offset(PrivateConstants.VerticalOffset)
            make.centerX.equalTo(containerView)
        }

        usernameView.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(titleLabel.snp_bottom).offset(PrivateConstants.FieldsOffset)
            make.left.equalTo(containerView).offset(PrivateConstants.HorizontalOffset)
            make.right.equalTo(containerView).offset(-PrivateConstants.HorizontalOffset)
        }

        profileView.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(usernameView.snp_bottom).offset(PrivateConstants.FieldsOffset)
            make.left.right.equalTo(usernameView)
        }

        goButton.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(profileView.snp_bottom).offset(PrivateConstants.VerticalOffset)
            make.left.right.equalTo(usernameView)
        }
    }
}
