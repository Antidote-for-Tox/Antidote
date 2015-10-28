//
//  LoginExtendedTextField.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 27/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let TextFieldHeight = 40.0
    static let VerticalOffset = 5.0
}

protocol LoginExtendedTextFieldDelegate: class {
    func loginExtendedTextFieldReturnKeyPressed(field: LoginExtendedTextField)
}

class LoginExtendedTextField: UIView {
    weak var delegate: LoginExtendedTextFieldDelegate?

    var maxTextUTF8Length: Int = Int.max

    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    var placeholder: String? {
        get {
            return textField.placeholder
        }
        set {
            textField.placeholder = newValue
        }
    }

    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }

    var hint: String? {
        get {
            return hintLabel.text
        }
        set {
            hintLabel.text = newValue
        }
    }

    var secureTextEntry: Bool {
        get {
            return textField.secureTextEntry
        }
        set {
            textField.secureTextEntry = newValue
        }
    }

    var returnKeyType: UIReturnKeyType {
        get {
            return textField.returnKeyType
        }
        set {
            textField.returnKeyType = newValue
        }
    }

    private let theme: Theme
    private var titleLabel: UILabel!
    private var textField: UITextField!
    private var hintLabel: UILabel!

    init(theme: Theme) {
        self.theme = theme

        super.init(frame: CGRectZero)

        createViews()
        installConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
}

extension LoginExtendedTextField: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        delegate?.loginExtendedTextFieldReturnKeyPressed(self)
        return false
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let resultText = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)

        if resultText.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) <= maxTextUTF8Length {
            return true
        }

        textField.text = resultText.substringToByteLength(maxTextUTF8Length, encoding: NSUTF8StringEncoding)
        return false
    }
}

private extension LoginExtendedTextField {
    func createViews() {
        titleLabel = UILabel()
        titleLabel.textColor = theme.colorForType(.LoginDescriptionLabel)
        titleLabel.font = UIFont.systemFontOfSize(18.0)
        titleLabel.backgroundColor = .clearColor()
        addSubview(titleLabel)

        textField = UITextField()
        textField.delegate = self
        textField.borderStyle = .RoundedRect
        textField.autocapitalizationType = .Sentences
        textField.enablesReturnKeyAutomatically = true
        addSubview(textField)

        hintLabel = UILabel()
        hintLabel.textColor = theme.colorForType(.LoginDescriptionLabel)
        hintLabel.font = UIFont.systemFontOfSize(14.0, weight: UIFontWeightLight)
        hintLabel.numberOfLines = 0
        hintLabel.backgroundColor = .clearColor()
        addSubview(hintLabel)
    }

    func installConstraints() {
        titleLabel.snp_makeConstraints{ (make) -> Void in
            make.top.left.right.equalTo(self)
        }

        textField.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(titleLabel.snp_bottom).offset(Constants.VerticalOffset)
            make.left.right.equalTo(self)
            make.height.equalTo(Constants.TextFieldHeight)
        }

        hintLabel.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(textField.snp_bottom).offset(Constants.VerticalOffset)
            make.left.right.equalTo(self)
            make.bottom.equalTo(self)
        }
    }
}
