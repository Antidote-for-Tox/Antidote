// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SnapKit

private struct PrivateConstants {
    static let FieldsOffset = 20.0
    static let VerticalOffset = 30.0
}

class LoginGenericCreateController: LoginBaseController {
    fileprivate var containerView: IncompressibleView!
    fileprivate var containerViewTopConstraint: Constraint!

    var titleLabel: UILabel!
    var firstTextField: ExtendedTextField!
    var secondTextField: ExtendedTextField!
    var bottomButton: RoundedButton!

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
        if containerView.frame.isEmpty {
            return
        }
        let underFormHeight = containerView.frame.size.height - secondTextField.frame.maxY

        let offset = min(0.0, underFormHeight - frame.height)

        containerViewTopConstraint.update(offset: offset)
        view.layoutIfNeeded()
    }

    override func keyboardWillHideAnimated(keyboardFrame frame: CGRect) {
        containerViewTopConstraint.update(offset: 0.0)
        view.layoutIfNeeded()
    }

    func configureViews() {
        fatalError("override in subclass")
    }
}

extension LoginGenericCreateController {
    @objc func tapOnView() {
        view.endEditing(true)
    }

    @objc func bottomButtonPressed() {
        fatalError("override in subclass")
    }
}

extension LoginGenericCreateController: ExtendedTextFieldDelegate {
    func loginExtendedTextFieldReturnKeyPressed(_ field: ExtendedTextField) {
        if field == firstTextField {
            _ = secondTextField.becomeFirstResponder()
        }
        else if field == secondTextField {
            view.endEditing(true)
            bottomButtonPressed()
        }
    }
}

private extension LoginGenericCreateController {
    func createGestureRecognizers() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(LoginCreateAccountController.tapOnView))
        view.addGestureRecognizer(tapGR)
    }

    func createContainerView() {
        containerView = IncompressibleView()
        containerView.backgroundColor = .clear
        view.addSubview(containerView)
    }

    func createTitleLabel() {
        titleLabel = UILabel()
        titleLabel.textColor = theme.colorForType(.LoginButtonBackground)
        titleLabel.font = UIFont.antidoteFontWithSize(26.0, weight: .light)
        titleLabel.backgroundColor = .clear
        containerView.addSubview(titleLabel)
    }

    func createExtendedTextFields() {
        firstTextField = ExtendedTextField(theme: theme, type: .login)
        firstTextField.delegate = self
        firstTextField.returnKeyType = .next
        containerView.addSubview(firstTextField)

        secondTextField = ExtendedTextField(theme: theme, type: .login)
        secondTextField.delegate = self
        secondTextField.returnKeyType = .go
        containerView.addSubview(secondTextField)
    }

    func createGoButton() {
        bottomButton = RoundedButton(theme: theme, type: .login)
        bottomButton.addTarget(self, action: #selector(LoginCreateAccountController.bottomButtonPressed), for: .touchUpInside)
        containerView.addSubview(bottomButton)
    }

    func installConstraints() {
        containerView.customIntrinsicContentSize.width = CGFloat(Constants.MaxFormWidth)
        containerView.snp.makeConstraints {
            containerViewTopConstraint = $0.top.equalTo(view).constraint
            $0.centerX.equalTo(view)
            $0.width.lessThanOrEqualTo(Constants.MaxFormWidth)
            $0.width.lessThanOrEqualTo(view).offset(-2 * Constants.HorizontalOffset)
            $0.height.equalTo(view)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(containerView).offset(PrivateConstants.VerticalOffset)
            $0.centerX.equalTo(containerView)
        }

        firstTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(PrivateConstants.FieldsOffset)
            $0.leading.equalTo(containerView)
            $0.trailing.equalTo(containerView)
        }

        secondTextField.snp.makeConstraints {
            $0.leading.trailing.equalTo(firstTextField)

            if firstTextField.isHidden {
                $0.top.equalTo(titleLabel.snp.bottom).offset(PrivateConstants.FieldsOffset)
            }
            else {
                $0.top.equalTo(firstTextField.snp.bottom).offset(PrivateConstants.FieldsOffset)
            }
        }

        bottomButton.snp.makeConstraints {
            $0.top.equalTo(secondTextField.snp.bottom).offset(PrivateConstants.VerticalOffset)
            $0.leading.trailing.equalTo(firstTextField)
        }
    }
}
