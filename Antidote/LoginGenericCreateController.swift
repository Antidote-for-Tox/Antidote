//
//  LoginGenericCreateController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 16/08/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation
import SnapKit

private struct PrivateConstants {
    static let FieldsOffset = 20.0
    static let VerticalOffset = 30.0
}

class LoginGenericCreateController: LoginBaseController {
    private var containerView: IncompressibleView!
    private var containerViewTopConstraint: Constraint!

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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        firstTextField.becomeFirstResponder()
    }

    override func keyboardWillShowAnimated(keyboardFrame frame: CGRect) {
        if CGRectIsEmpty(containerView.frame) {
            return
        }
        let underFormHeight = containerView.frame.size.height - CGRectGetMaxY(secondTextField.frame)

        let offset = min(0.0, underFormHeight - frame.height)

        containerViewTopConstraint.updateOffset(offset)
        view.layoutIfNeeded()
    }

    override func keyboardWillHideAnimated(keyboardFrame frame: CGRect) {
        containerViewTopConstraint.updateOffset(0.0)
        view.layoutIfNeeded()
    }

    func configureViews() {
        fatalError("override in subclass")
    }
}

extension LoginGenericCreateController {
    func tapOnView() {
        view.endEditing(true)
    }

    func bottomButtonPressed() {
        fatalError("override in subclass")
    }
}

extension LoginGenericCreateController: ExtendedTextFieldDelegate {
    func loginExtendedTextFieldReturnKeyPressed(field: ExtendedTextField) {
        if field == firstTextField {
            secondTextField.becomeFirstResponder()
        }
        else if field == secondTextField {
            secondTextField.resignFirstResponder()
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
        containerView.backgroundColor = .clearColor()
        view.addSubview(containerView)
    }

    func createTitleLabel() {
        titleLabel = UILabel()
        titleLabel.textColor = theme.colorForType(.LoginButtonBackground)
        titleLabel.font = UIFont.antidoteFontWithSize(26.0, weight: .Light)
        titleLabel.backgroundColor = .clearColor()
        containerView.addSubview(titleLabel)
    }

    func createExtendedTextFields() {
        firstTextField = ExtendedTextField(theme: theme, type: .Login)
        firstTextField.delegate = self
        firstTextField.returnKeyType = .Next
        containerView.addSubview(firstTextField)

        secondTextField = ExtendedTextField(theme: theme, type: .Login)
        secondTextField.delegate = self
        secondTextField.returnKeyType = .Go
        containerView.addSubview(secondTextField)
    }

    func createGoButton() {
        bottomButton = RoundedButton(theme: theme, type: .Login)
        bottomButton.addTarget(self, action: #selector(LoginCreateAccountController.bottomButtonPressed), forControlEvents: .TouchUpInside)
        containerView.addSubview(bottomButton)
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

        firstTextField.snp_makeConstraints {
            $0.top.equalTo(titleLabel.snp_bottom).offset(PrivateConstants.FieldsOffset)
            $0.leading.equalTo(containerView)
            $0.trailing.equalTo(containerView)
        }

        secondTextField.snp_makeConstraints {
            $0.leading.trailing.equalTo(firstTextField)

            if firstTextField.hidden {
                $0.top.equalTo(titleLabel.snp_bottom).offset(PrivateConstants.FieldsOffset)
            }
            else {
                $0.top.equalTo(firstTextField.snp_bottom).offset(PrivateConstants.FieldsOffset)
            }
        }

        bottomButton.snp_makeConstraints {
            $0.top.equalTo(secondTextField.snp_bottom).offset(PrivateConstants.VerticalOffset)
            $0.leading.trailing.equalTo(firstTextField)
        }
    }
}
