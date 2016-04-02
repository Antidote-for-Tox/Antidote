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
}

protocol LoginCreateAccountControllerDelegate: class {
    func loginCreateAccountControllerCreate(controller: LoginCreateAccountController, name: String, profile: String)
    func loginCreateAccountControllerImport(controller: LoginCreateAccountController, profile: String, userInfo: AnyObject?)
}

class LoginCreateAccountController: LoginBaseController {
    enum Type {
        case CreateAccount
        case ImportProfile(userInfo: AnyObject?)
    }

    weak var delegate: LoginCreateAccountControllerDelegate?

    private let type: Type

    private var containerView: IncompressibleView!
    private var containerViewTopConstraint: Constraint!

    private var titleLabel: UILabel!
    private var usernameView: ExtendedTextField!
    private var profileView: ExtendedTextField!
    private var goButton: RoundedButton!

    init(theme: Theme, type: Type) {
        self.type = type

        super.init(theme: theme)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        createGestureRecognizers()
        createContainerView()
        createTitleLabel()
        createExtendedTextFields()
        createGoButton()
        configureViews()

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
        let profile = profileView.text ?? ""

        switch type {
            case .CreateAccount:
                let name = usernameView.text ?? ""
                delegate?.loginCreateAccountControllerCreate(self, name: name, profile: profile)
            case .ImportProfile(let userInfo):
                delegate?.loginCreateAccountControllerImport(self, profile: profile, userInfo: userInfo)
        }
    }
}

extension LoginCreateAccountController: ExtendedTextFieldDelegate {
    func loginExtendedTextFieldReturnKeyPressed(field: ExtendedTextField) {
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
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(LoginCreateAccountController.tapOnView))
        view.addGestureRecognizer(tapGR)
    }

    func createContainerView() {
        containerView = IncompressibleView()
        containerView.backgroundColor = .clearColor()
        view.addSubview(containerView)
    }

    func createTitleLabel() {
        titleLabel = UILabel()
        titleLabel.textColor = theme.colorForType(.LoginButtonText)
        titleLabel.font = UIFont.systemFontOfSize(26.0, weight: UIFontWeightLight)
        titleLabel.backgroundColor = .clearColor()
        containerView.addSubview(titleLabel)
    }

    func createExtendedTextFields() {
        usernameView = ExtendedTextField(theme: theme, type: .Login)
        usernameView.delegate = self
        usernameView.title = String(localized: "create_account_username_title")
        usernameView.placeholder = String(localized: "create_account_username_placeholder")
        usernameView.returnKeyType = .Next
        usernameView.maxTextUTF8Length = Int(kOCTToxMaxNameLength)
        containerView.addSubview(usernameView)

        profileView = ExtendedTextField(theme: theme, type: .Login)
        profileView.delegate = self
        profileView.title = String(localized: "create_account_profile_title")
        profileView.placeholder = String(localized: "create_account_profile_placeholder")
        profileView.hint = String(localized: "create_account_profile_hint")
        profileView.returnKeyType = .Go
        containerView.addSubview(profileView)
    }

    func createGoButton() {
        goButton = RoundedButton(theme: theme, type: .Login)
        goButton.setTitle(String(localized: "create_account_go_button"), forState: .Normal)
        goButton.addTarget(self, action: #selector(LoginCreateAccountController.goButtonPressed), forControlEvents: .TouchUpInside)
        containerView.addSubview(goButton)
    }

    func configureViews() {
        switch type {
            case .CreateAccount:
                titleLabel.text = String(localized: "create_profile")
            case .ImportProfile:
                titleLabel.text = String(localized: "import_profile")
                usernameView.hidden = true
        }
    }

    func installConstraints() {
        containerView.customIntrinsicContentSize.width = CGFloat(Constants.MaxFormWidth)
        containerView.snp_makeConstraints {
            containerViewTopConstraint = $0.top.equalTo(view).constraint
            $0.centerX.equalTo(view)
            $0.width.lessThanOrEqualTo(Constants.MaxFormWidth)
            $0.width.lessThanOrEqualTo(view).offset(-2 * Constants.HorizontalOffset)
            $0.height.equalTo(view)
        }

        titleLabel.snp_makeConstraints {
            $0.top.equalTo(containerView).offset(PrivateConstants.VerticalOffset)
            $0.centerX.equalTo(containerView)
        }

        usernameView.snp_makeConstraints {
            $0.top.equalTo(titleLabel.snp_bottom).offset(PrivateConstants.FieldsOffset)
            $0.left.equalTo(containerView)
            $0.right.equalTo(containerView)
        }

        profileView.snp_makeConstraints {
            $0.left.right.equalTo(usernameView)

            switch type {
                case .CreateAccount:
                    $0.top.equalTo(usernameView.snp_bottom).offset(PrivateConstants.FieldsOffset)
                case .ImportProfile:
                    $0.top.equalTo(titleLabel.snp_bottom).offset(PrivateConstants.FieldsOffset)
            }
        }

        goButton.snp_makeConstraints {
            $0.top.equalTo(profileView.snp_bottom).offset(PrivateConstants.VerticalOffset)
            $0.left.right.equalTo(usernameView)
        }
    }
}
