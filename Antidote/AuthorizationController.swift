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
    func authorizationControllerCancel(controller: AuthorizationController)
}

private struct Constants {
    static let TopOffset = 40.0
    static let HorizontalOffset = 40.0
    static let MaxFormWidth = 350.0
}

class AuthorizationController: KeyboardNotificationController {
    enum CancelButtonType {
        case Cancel
        case Logout
    }

    weak var delegate: AuthorizationControllerDelegate?

    let theme: Theme

    private var containerView: IncompressibleView!
    private var passwordField: ExtendedTextField!
    
    init(theme: Theme, cancelButtonType: CancelButtonType) {
        self.theme = theme

        super.init()

        edgesForExtendedLayout = .None
        addNavigationButtons(cancelButtonType: cancelButtonType)
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
        delegate?.authorizationControllerCancel(self)
    }
}

extension AuthorizationController: ExtendedTextFieldDelegate {
    func loginExtendedTextFieldReturnKeyPressed(field: ExtendedTextField) {
        let password = field.text ?? ""
        delegate?.authorizationController(self, authorizeWithPassword: password)
    }
}

private extension AuthorizationController {
    func addNavigationButtons(cancelButtonType cancelButtonType: CancelButtonType) {
        let title: String
        switch cancelButtonType {
            case .Cancel:
                title = String(localized: "alert_cancel")
            case .Logout:
                title = String(localized: "logout_button")
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: title,
                style: .Done,
                target: self,
                action: #selector(AuthorizationController.logoutButtonPressed))
    }

    func createViews() {
        containerView = IncompressibleView()
        view.addSubview(containerView)

        passwordField = ExtendedTextField(theme: theme, type: .Normal)
        passwordField.delegate = self
        passwordField.placeholder = String(localized: "password")
        passwordField.secureTextEntry = true
        passwordField.returnKeyType = .Done
        containerView.addSubview(passwordField)
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

        passwordField.snp_makeConstraints {
            $0.top.equalTo(containerView)
            $0.leading.trailing.equalTo(containerView)
        }
    }
}
