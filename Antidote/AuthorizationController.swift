//
//  AuthorizationController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 13/08/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation
import SnapKit

protocol AuthorizationControllerDelegate: class {
    func authorizationController(controller: AuthorizationController, authorizeWithPassword password: String)
    func authorizationControllerLogout(controller: AuthorizationController)
}

private struct Constants {
    static let TopOffset = 40.0
    static let HorizontalOffset = 40.0
    static let MaxFormWidth = 350.0
}

class AuthorizationController: KeyboardNotificationController {
    weak var delegate: AuthorizationControllerDelegate?

    let theme: Theme
    let profileName: String

    private var containerView: IncompressibleView!
    private var profileNameLabel: UILabel!
    private var passwordField: ExtendedTextField!
    private var logoutButton: UIButton!
    
    init(theme: Theme, profileName: String) {
        self.theme = theme
        self.profileName = profileName

        super.init()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        createViews()
        installConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)

        passwordField.becomeFirstResponder()
    }
}

// Actions
extension AuthorizationController {
    func logoutButtonPressed() {
        delegate?.authorizationControllerLogout(self)
    }
}

extension AuthorizationController: ExtendedTextFieldDelegate {
    func loginExtendedTextFieldReturnKeyPressed(field: ExtendedTextField) {
        let password = field.text ?? ""
        delegate?.authorizationController(self, authorizeWithPassword: password)
    }
}

private extension AuthorizationController {
    func createViews() {
        containerView = IncompressibleView()
        view.addSubview(containerView)

        profileNameLabel = UILabel()
        profileNameLabel.text = profileName
        containerView.addSubview(profileNameLabel)

        passwordField = ExtendedTextField(theme: theme, type: .Normal)
        passwordField.delegate = self
        passwordField.placeholder = String(localized: "password")
        passwordField.secureTextEntry = true
        passwordField.returnKeyType = .Done
        containerView.addSubview(passwordField)

        logoutButton = UIButton(type: .System)
        logoutButton.setTitle(String(localized: "logout_button"), forState: .Normal)
        logoutButton.addTarget(self, action: #selector(AuthorizationController.logoutButtonPressed), forControlEvents: .TouchUpInside)
        containerView.addSubview(logoutButton)
    }
    
    func installConstraints() {
        containerView.customIntrinsicContentSize.width = CGFloat(Constants.MaxFormWidth)
        containerView.snp_makeConstraints {
            $0.top.equalTo(view)
            $0.bottom.equalTo(view)
            $0.centerX.equalTo(view)
            $0.width.lessThanOrEqualTo(Constants.MaxFormWidth)
            $0.width.lessThanOrEqualTo(view).offset(-2 * Constants.HorizontalOffset)
        }

        profileNameLabel.snp_makeConstraints {
            $0.top.equalTo(containerView).offset(Constants.TopOffset)
            $0.centerX.equalTo(containerView)
        }

        passwordField.snp_makeConstraints {
            $0.top.equalTo(profileNameLabel.snp_bottom)
            $0.leading.trailing.equalTo(containerView)
        }

        logoutButton.snp_makeConstraints {
            $0.top.equalTo(passwordField.snp_bottom)
            $0.centerX.equalTo(containerView)
        }
    }
}
