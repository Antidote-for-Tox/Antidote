//
//  PasswordController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 31.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let HorizontalOffset = 40.0
    static let ButtonVerticalOffset = 20.0
    static let FieldsOffset = 10.0

    static let MaxFormWidth = 350.0
}

protocol PasswordControllerDelegate: class {
    func passwordControllerDidFinishPresenting(controller: PasswordController)
}

class PasswordController: KeyboardNotificationController {
    enum ControllerType {
        case SetNewPassword
        case DeletePassword
    }

    weak var delegate: PasswordControllerDelegate?

    private let theme: Theme
    private let type: ControllerType

    private weak var toxManager: OCTManager!

    private var containerView: IncompressibleView!
    private var containerViewTopConstraint: Constraint!

    private var oldPasswordField: ExtendedTextField?
    private var newPasswordField: ExtendedTextField?
    private var repeatPasswordField: ExtendedTextField?
    private var button: RoundedButton!

    init(theme: Theme, type: ControllerType, toxManager: OCTManager) {
        self.theme = theme
        self.type = type
        self.toxManager = toxManager

        super.init()

        edgesForExtendedLayout = .None
        addNavigationButtons()

        switch type {
            case .SetNewPassword:
                title = String(localized: "change_password")
            case .DeletePassword:
                title = String(localized: "delete_password")
        }
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        createViews()
        installConstraints()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if let old = oldPasswordField {
            old.becomeFirstResponder()
        }
        else if let new = newPasswordField {
            new.becomeFirstResponder()
        }
    }

    override func keyboardWillShowAnimated(keyboardFrame frame: CGRect) {
        let underFormHeight = containerView.frame.size.height - CGRectGetMaxY(button.frame)

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
extension PasswordController {
    func cancelButtonPressed() {
        delegate?.passwordControllerDidFinishPresenting(self)
    }

    func buttonPressed() {
        guard validateOldPassword() else {
            return
        }

        guard validateNewPassword() else {
            return
        }

        switch type {
            case .SetNewPassword:
                toxManager.changePassphrase(newPasswordField!.text!)
            case .DeletePassword:
                toxManager.changePassphrase(nil)
        }

        delegate?.passwordControllerDidFinishPresenting(self)
    }
}

extension PasswordController: ExtendedTextFieldDelegate {
    func loginExtendedTextFieldReturnKeyPressed(field: ExtendedTextField) {
        switch type {
            case .SetNewPassword:
                if field === oldPasswordField {
                    newPasswordField!.becomeFirstResponder()
                }
                else if field === newPasswordField {
                    repeatPasswordField!.becomeFirstResponder()
                }
                else if field === repeatPasswordField {
                    buttonPressed()
                }
            case .DeletePassword:
                buttonPressed()
        }
    }
}

private extension PasswordController {
    func addNavigationButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .Cancel,
                target: self,
                action: #selector(PasswordController.cancelButtonPressed))
    }

    func createViews() {
        containerView = IncompressibleView()
        containerView.backgroundColor = .clearColor()
        view.addSubview(containerView)

        button = RoundedButton(theme: theme, type: .RunningPositive)
        button.setTitle(String(localized: "change_password_done"), forState: .Normal)
        button.addTarget(self, action: #selector(PasswordController.buttonPressed), forControlEvents: .TouchUpInside)
        containerView.addSubview(button)

        switch type {
            case .SetNewPassword:
                if hasOldPassword() {
                    oldPasswordField = createPasswordFieldWithTitle(String(localized: "old_password"))
                }
                newPasswordField = createPasswordFieldWithTitle(String(localized: "new_password"))
                repeatPasswordField = createPasswordFieldWithTitle(String(localized: "repeat_password"))

                oldPasswordField?.returnKeyType = .Next
                newPasswordField?.returnKeyType = .Next
                repeatPasswordField?.returnKeyType = .Done

            case .DeletePassword:
                oldPasswordField = createPasswordFieldWithTitle(String(localized: "old_password"))
                oldPasswordField?.returnKeyType = .Done
        }
    }

    func createPasswordFieldWithTitle(title: String) -> ExtendedTextField {
        let field = ExtendedTextField(theme: theme, type: .Normal)
        field.delegate = self
        field.title = title
        field.secureTextEntry = true
        containerView.addSubview(field)

        return field
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

        var topConstraint = containerView.snp_top

        if installConstraintsForField(oldPasswordField, topConstraint: topConstraint) {
            topConstraint = oldPasswordField!.snp_bottom
        }

        if installConstraintsForField(newPasswordField, topConstraint: topConstraint) {
            topConstraint = newPasswordField!.snp_bottom
        }

        if installConstraintsForField(repeatPasswordField, topConstraint: topConstraint) {
            topConstraint = repeatPasswordField!.snp_bottom
        }

        button.snp_makeConstraints {
            $0.top.equalTo(topConstraint).offset(Constants.ButtonVerticalOffset)
            $0.left.right.equalTo(containerView)
        }
    }

    /**
        Returns true if field exists, no otherwise.
     */
    func installConstraintsForField(field: ExtendedTextField?, topConstraint: ConstraintItem) -> Bool {
        guard let field = field else {
            return false
        }

        field.snp_makeConstraints {
            $0.top.equalTo(topConstraint).offset(Constants.FieldsOffset)
            $0.left.right.equalTo(containerView)
        }

        return true
    }

    func hasOldPassword() -> Bool {
        if let passphrase = toxManager.configuration().passphrase where !passphrase.isEmpty {
            return true
        }

        return false
    }

    func validateOldPassword() -> Bool {
        guard let oldPasswordField = oldPasswordField else {
            // no password field, no need for validation
            return true
        }

        guard let text = oldPasswordField.text where !text.isEmpty else {
            handleErrorWithType(.PasswordIsEmpty)
            return false
        }

        guard text == toxManager.configuration().passphrase! else {
            handleErrorWithType(.WrongOldPassword)
            return false
        }

        return true
    }

    func validateNewPassword() -> Bool {
        guard let newPasswordField = newPasswordField,
              let repeatPasswordField = repeatPasswordField else {
            // no password fields, no need for validation
            return true
        }

        guard let newText = newPasswordField.text where !newText.isEmpty else {
            handleErrorWithType(.PasswordIsEmpty)
            return false
        }

        guard let repeatText = repeatPasswordField.text where !repeatText.isEmpty else {
            handleErrorWithType(.PasswordIsEmpty)
            return false
        }

        guard newText == repeatText else {
            handleErrorWithType(.PasswordsDoNotMatch)
            return false
        }

        return true
    }
}
