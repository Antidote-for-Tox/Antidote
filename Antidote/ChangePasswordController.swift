// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

private struct Constants {
    static let HorizontalOffset = 40.0
    static let ButtonVerticalOffset = 20.0
    static let FieldsOffset = 10.0

    static let MaxFormWidth = 350.0
}

protocol ChangePasswordControllerDelegate: class {
    func changePasswordControllerDidFinishPresenting(_ controller: ChangePasswordController)
}

class ChangePasswordController: KeyboardNotificationController {
    weak var delegate: ChangePasswordControllerDelegate?

    fileprivate let theme: Theme

    fileprivate weak var toxManager: OCTManager!

    fileprivate var scrollView: UIScrollView!
    fileprivate var containerView: IncompressibleView!

    fileprivate var oldPasswordField: ExtendedTextField!
    fileprivate var newPasswordField: ExtendedTextField!
    fileprivate var repeatPasswordField: ExtendedTextField!
    fileprivate var button: RoundedButton!

    init(theme: Theme, toxManager: OCTManager) {
        self.theme = theme
        self.toxManager = toxManager

        super.init()

        edgesForExtendedLayout = UIRectEdge()
        addNavigationButtons()

        title = String(localized: "change_password")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        createViews()
        installConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let old = oldPasswordField {
            _ = old.becomeFirstResponder()
        }
        else if let new = newPasswordField {
            _ = new.becomeFirstResponder()
        }
    }

    override func keyboardWillShowAnimated(keyboardFrame frame: CGRect) {
        scrollView.contentInset.bottom = frame.size.height
        scrollView.scrollIndicatorInsets.bottom = frame.size.height
    }

    override func keyboardWillHideAnimated(keyboardFrame frame: CGRect) {
        scrollView.contentInset.bottom = 0.0
        scrollView.scrollIndicatorInsets.bottom = 0.0
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.contentSize.width = scrollView.frame.size.width
        scrollView.contentSize.height = containerView.frame.maxY
    }
}

// MARK: Actions
extension ChangePasswordController {
    @objc func cancelButtonPressed() {
        delegate?.changePasswordControllerDidFinishPresenting(self)
    }

    @objc func buttonPressed() {
        guard validatePasswordFields() else {
            return
        }

        let oldPassword = oldPasswordField.text!
        let newPassword = newPasswordField.text!

        let hud = JGProgressHUD(style: .dark)
        hud?.show(in: view)

        DispatchQueue.global(qos: .default).async { [unowned self] in
            let result = self.toxManager.changeEncryptPassword(newPassword, oldPassword: oldPassword)

            if result {
                let keychainManager = KeychainManager()
                if keychainManager.toxPasswordForActiveAccount != nil {
                    keychainManager.toxPasswordForActiveAccount = newPassword
                }
            }

            DispatchQueue.main.async { [unowned self] in
                hud?.dismiss()

                if result {
                    self.delegate?.changePasswordControllerDidFinishPresenting(self)
                }
                else {
                    handleErrorWithType(.wrongOldPassword)
                }
            }
        }
    }
}

extension ChangePasswordController: ExtendedTextFieldDelegate {
    func loginExtendedTextFieldReturnKeyPressed(_ field: ExtendedTextField) {
        if field === oldPasswordField {
            _ = newPasswordField!.becomeFirstResponder()
        }
        else if field === newPasswordField {
            _ = repeatPasswordField!.becomeFirstResponder()
        }
        else if field === repeatPasswordField {
            buttonPressed()
        }
    }
}

private extension ChangePasswordController {
    func addNavigationButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(ChangePasswordController.cancelButtonPressed))
    }

    func createViews() {
        scrollView = UIScrollView()
        view.addSubview(scrollView)

        containerView = IncompressibleView()
        containerView.backgroundColor = .clear
        scrollView.addSubview(containerView)

        button = RoundedButton(theme: theme, type: .runningPositive)
        button.setTitle(String(localized: "change_password_done"), for: UIControlState())
        button.addTarget(self, action: #selector(ChangePasswordController.buttonPressed), for: .touchUpInside)
        containerView.addSubview(button)

        oldPasswordField = createPasswordFieldWithTitle(String(localized: "old_password"))
        newPasswordField = createPasswordFieldWithTitle(String(localized: "new_password"))
        repeatPasswordField = createPasswordFieldWithTitle(String(localized: "repeat_password"))

        oldPasswordField.returnKeyType = .next
        newPasswordField.returnKeyType = .next
        repeatPasswordField.returnKeyType = .done
    }

    func createPasswordFieldWithTitle(_ title: String) -> ExtendedTextField {
        let field = ExtendedTextField(theme: theme, type: .normal)
        field.delegate = self
        field.title = title
        field.secureTextEntry = true
        containerView.addSubview(field)

        return field
    }

    func installConstraints() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }

        containerView.customIntrinsicContentSize.width = CGFloat(Constants.MaxFormWidth)
        containerView.snp.makeConstraints {
            $0.top.equalTo(scrollView)
            $0.centerX.equalTo(scrollView)
            $0.width.lessThanOrEqualTo(Constants.MaxFormWidth)
            $0.width.lessThanOrEqualTo(scrollView).offset(-2 * Constants.HorizontalOffset)
        }

        var topConstraint = containerView.snp.top

        if installConstraintsForField(oldPasswordField, topConstraint: topConstraint) {
            topConstraint = oldPasswordField!.snp.bottom
        }

        if installConstraintsForField(newPasswordField, topConstraint: topConstraint) {
            topConstraint = newPasswordField!.snp.bottom
        }

        if installConstraintsForField(repeatPasswordField, topConstraint: topConstraint) {
            topConstraint = repeatPasswordField!.snp.bottom
        }

        button.snp.makeConstraints {
            $0.top.equalTo(topConstraint).offset(Constants.ButtonVerticalOffset)
            $0.leading.trailing.equalTo(containerView)
            $0.bottom.equalTo(containerView)
        }
    }

    /**
        Returns true if field exists, no otherwise.
     */
    func installConstraintsForField(_ field: ExtendedTextField?, topConstraint: ConstraintItem) -> Bool {
        guard let field = field else {
            return false
        }

        field.snp.makeConstraints {
            $0.top.equalTo(topConstraint).offset(Constants.FieldsOffset)
            $0.leading.trailing.equalTo(containerView)
        }

        return true
    }

    func validatePasswordFields() -> Bool {
        guard let oldText = oldPasswordField.text, !oldText.isEmpty else {
            handleErrorWithType(.passwordIsEmpty)
            return false
        }
        guard let newText = newPasswordField.text, !newText.isEmpty else {
            handleErrorWithType(.passwordIsEmpty)
            return false
        }

        guard let repeatText = repeatPasswordField.text, !repeatText.isEmpty else {
            handleErrorWithType(.passwordIsEmpty)
            return false
        }

        guard newText == repeatText else {
            handleErrorWithType(.passwordsDoNotMatch)
            return false
        }

        return true
    }
}
