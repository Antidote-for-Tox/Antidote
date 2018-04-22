// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

protocol LoginFormControllerDelegate: class {
    func loginFormControllerLogin(_ controller: LoginFormController, profileName: String, password: String?)
    func loginFormControllerCreateAccount(_ controller: LoginFormController)
    func loginFormControllerImportProfile(_ controller: LoginFormController)

    func loginFormController(_ controller: LoginFormController, isProfileEncrypted profile: String) -> Bool
}

class LoginFormController: LoginLogoController {
    fileprivate struct PrivateConstants {
        static let IconContainerWidth: CGFloat = Constants.TextFieldHeight - 15.0
        static let IconContainerHeight: CGFloat = Constants.TextFieldHeight

        static let FormOffset = 20.0
        static let FormSmallOffset = 10.0

        static let AnimationDuration = 0.3
    }

    weak var delegate: LoginFormControllerDelegate?

    fileprivate var formView: IncompressibleView!
    fileprivate var profileFakeTextField: UITextField!
    fileprivate var profileButton: UIButton!
    fileprivate var passwordField: UITextField!

    fileprivate var loginButton: RoundedButton!

    fileprivate var bottomButtonsContainer: UIView!
    fileprivate var createAccountButton: UIButton!
    fileprivate var orLabel: UILabel!
    fileprivate var importProfileButton: UIButton!

    fileprivate var profileButtonBottomToFormConstraint: Constraint!
    fileprivate var passwordFieldBottomToFormConstraint: Constraint!

    fileprivate let profileNames: [String]
    fileprivate var selectedIndex: Int

    init(theme: Theme, profileNames: [String], selectedIndex: Int) {
        self.profileNames = profileNames
        self.selectedIndex = selectedIndex

        super.init(theme: theme)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()

        createGestureRecognizers()
        createFormViews()
        createLoginButton()
        createBottomButtons()

        installConstraints()

        updateFormAnimated(false)
    }

    override func keyboardWillShowAnimated(keyboardFrame frame: CGRect) {
        guard navigationController?.topViewController == self else {
            return
        }
        let underLoginHeight =
            mainContainerView.frame.size.height -
            contentContainerView.frame.origin.y -
            loginButton.frame.maxY

        let offset = min(0.0, underLoginHeight - frame.height)

        mainContainerViewTopConstraint?.update(offset: offset)
        view.layoutIfNeeded()
    }

    override func keyboardWillHideAnimated(keyboardFrame frame: CGRect) {
        mainContainerViewTopConstraint?.update(offset: 0.0)
        view.layoutIfNeeded()
    }
}

// MARK: Actions
extension LoginFormController {
    @objc func profileButtonPressed() {
        view.endEditing(true)

        let picker = FullscreenPicker(theme: theme, strings: profileNames, selectedIndex: selectedIndex)
        picker.delegate = self

        contentContainerView.accessibilityElementsHidden = true
        picker.showAnimatedInView(view)
}

    @objc func loginButtonPressed() {
        let isEmpty = (passwordField.text == nil) || passwordField.text!.isEmpty
        let password = isEmpty ? nil : passwordField.text

        delegate?.loginFormControllerLogin(self, profileName: profileNames[selectedIndex], password: password)
    }

    @objc func createAccountButtonPressed() {
        delegate?.loginFormControllerCreateAccount(self)
    }

    @objc func importProfileButtonPressed() {
        delegate?.loginFormControllerImportProfile(self)
    }

    @objc func tapOnView() {
        view.endEditing(true)
    }
}

extension LoginFormController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loginButtonPressed()
        return true
    }
}

extension LoginFormController: FullscreenPickerDelegate {
    func fullscreenPicker(_ picker: FullscreenPicker, willDismissWithSelectedIndex index: Int) {
        contentContainerView.accessibilityElementsHidden = false
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.profileButton);

        if index == selectedIndex {
            return
        }
        selectedIndex = index

        updateFormAnimated(true)
    }
}

private extension LoginFormController {
    func createGestureRecognizers() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(LoginFormController.tapOnView))
        view.addGestureRecognizer(tapGR)
    }

    func createFormViews() {
        formView = IncompressibleView()
        formView.backgroundColor = .clear
        formView.layer.cornerRadius = 5.0
        formView.layer.masksToBounds = true
        contentContainerView.addSubview(formView)

        profileFakeTextField = UITextField()
        profileFakeTextField.leftViewMode = .always
        profileFakeTextField.leftView = iconContainerWithImageName("login-profile-icon")
        profileFakeTextField.borderStyle = .roundedRect
        profileFakeTextField.layer.borderColor = theme.colorForType(.LoginButtonBackground).cgColor
        profileFakeTextField.layer.borderWidth = 0.5
        profileFakeTextField.layer.masksToBounds = true
        profileFakeTextField.layer.cornerRadius = 6.0
        profileFakeTextField.isAccessibilityElement = false
        profileFakeTextField.accessibilityElementsHidden = true
        formView.addSubview(profileFakeTextField)

        profileButton = UIButton()
        profileButton.addTarget(self, action: #selector(LoginFormController.profileButtonPressed), for:.touchUpInside)
        profileButton.accessibilityLabel = String(localized: "profile_title")
        formView.addSubview(profileButton)

        passwordField = UITextField()
        passwordField.delegate = self
        passwordField.placeholder = String(localized:"password")
        passwordField.isSecureTextEntry = true
        passwordField.returnKeyType = .go
        passwordField.borderStyle = .roundedRect
        passwordField.leftViewMode = .always
        passwordField.leftView = iconContainerWithImageName("login-password-icon")
        passwordField.layer.borderColor = theme.colorForType(.LoginButtonBackground).cgColor
        passwordField.layer.borderWidth = 0.5
        passwordField.layer.masksToBounds = true
        passwordField.layer.cornerRadius = 6.0
        formView.addSubview(passwordField)
    }

    func createLoginButton() {
        loginButton = RoundedButton(theme: theme, type: .login)
        loginButton.setTitle(String(localized:"log_in"), for: UIControlState())
        loginButton.addTarget(self, action: #selector(LoginFormController.loginButtonPressed), for: .touchUpInside)
        contentContainerView.addSubview(loginButton)
    }

    func createBottomButtons() {
        bottomButtonsContainer = UIView()
        bottomButtonsContainer.backgroundColor = .clear
        contentContainerView.addSubview(bottomButtonsContainer)

        createAccountButton = createDescriptionButtonWithTitle(
            String(localized: "create_profile"),
            action: #selector(LoginFormController.createAccountButtonPressed))
        bottomButtonsContainer.addSubview(createAccountButton)

        orLabel = UILabel()
        orLabel.text = String(localized: "login_or_label")
        orLabel.textColor = theme.colorForType(.LoginButtonBackground)
        orLabel.backgroundColor = .clear
        bottomButtonsContainer.addSubview(orLabel)

        importProfileButton = createDescriptionButtonWithTitle(
                String(localized:"import_to_antidote"),
                action: #selector(LoginFormController.importProfileButtonPressed))
        bottomButtonsContainer.addSubview(importProfileButton)
    }

    func installConstraints() {
        formView.customIntrinsicContentSize.width = CGFloat(Constants.MaxFormWidth)
        formView.snp.makeConstraints {
            $0.top.equalTo(contentContainerView)
            $0.centerX.equalTo(contentContainerView)
            $0.width.lessThanOrEqualTo(Constants.MaxFormWidth)
            $0.width.lessThanOrEqualTo(contentContainerView).offset(-2 * Constants.HorizontalOffset)
        }

        profileFakeTextField.snp.makeConstraints {
            $0.edges.equalTo(profileButton)
        }

        profileButton.snp.makeConstraints {
            $0.top.equalTo(formView).offset(PrivateConstants.FormOffset)
            $0.leading.equalTo(formView)
            $0.trailing.equalTo(formView)
            profileButtonBottomToFormConstraint = $0.bottom.equalTo(formView).offset(-PrivateConstants.FormOffset).constraint

            $0.height.equalTo(Constants.TextFieldHeight)
        }

        passwordField.snp.makeConstraints {
            $0.top.equalTo(profileButton.snp.bottom).offset(PrivateConstants.FormSmallOffset)
            $0.leading.trailing.equalTo(profileButton)
            passwordFieldBottomToFormConstraint = $0.bottom.equalTo(formView).offset(-PrivateConstants.FormOffset).constraint

            $0.height.equalTo(Constants.TextFieldHeight)
        }

        loginButton.snp.makeConstraints {
            $0.top.equalTo(formView.snp.bottom).offset(PrivateConstants.FormSmallOffset)
            $0.leading.trailing.equalTo(formView)
        }

        bottomButtonsContainer.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(loginButton.snp.bottom).offset(PrivateConstants.FormOffset)
            $0.centerX.equalTo(view)
            $0.bottom.equalTo(view).offset(-PrivateConstants.FormOffset)
        }

        createAccountButton.snp.makeConstraints {
            $0.top.leading.bottom.equalTo(bottomButtonsContainer)
        }

        orLabel.snp.makeConstraints {
            $0.centerY.equalTo(bottomButtonsContainer)
            $0.leading.equalTo(createAccountButton.snp.trailing).offset(PrivateConstants.FormSmallOffset)
            $0.trailing.equalTo(importProfileButton.snp.leading).offset(-PrivateConstants.FormSmallOffset)
        }

        importProfileButton.snp.makeConstraints {
            $0.top.trailing.bottom.equalTo(bottomButtonsContainer)
        }
    }

    func iconContainerWithImageName(_ imageName: String) -> UIView {
        let image = UIImage.templateNamed(imageName)

        let imageView = UIImageView(image: image)
        imageView.tintColor = UIColor(white: 200.0/255.0, alpha:1.0)

        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(imageView)

        container.frame.size.width = PrivateConstants.IconContainerWidth
        container.frame.size.height = PrivateConstants.IconContainerHeight

        imageView.frame.origin.x = PrivateConstants.IconContainerWidth - imageView.frame.size.width
        imageView.frame.origin.y = (PrivateConstants.IconContainerHeight - imageView.frame.size.height) / 2 - 1.0

        return container
    }

    func createDescriptionButtonWithTitle(_ title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: UIControlState())
        button.setTitleColor(theme.colorForType(.LoginLinkColor), for: UIControlState())
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        button.addTarget(self, action: action, for: .touchUpInside)

        return button
    }

    func updateFormAnimated(_ animated: Bool) {
        let profileName = profileNames[selectedIndex]

        profileFakeTextField.text = profileName
        profileButton.accessibilityValue = profileName
        passwordField.text = nil

        let isEncrypted = delegate?.loginFormController(self, isProfileEncrypted: profileName) ?? false

        showPasswordField(isEncrypted, animated: animated)
    }

    func showPasswordField(_ show: Bool, animated: Bool) {
        func updateForm() {
            if (show) {
                profileButtonBottomToFormConstraint.deactivate()
                passwordFieldBottomToFormConstraint.activate()
                passwordField.alpha = 1.0
            }
            else {
                profileButtonBottomToFormConstraint.activate()
                passwordFieldBottomToFormConstraint.deactivate()
                passwordField.alpha = 0.0
            }

            view.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: PrivateConstants.AnimationDuration, animations: updateForm)
        }
        else {
            updateForm()
        }
    }
}
