// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

private struct Constants {
    static let TextFieldHeight = 40.0
    static let VerticalOffset = 5.0
}

protocol ExtendedTextFieldDelegate: class {
    func loginExtendedTextFieldReturnKeyPressed(field: ExtendedTextField)
}

class ExtendedTextField: UIView {
    enum Type {
        case Login
        case Normal
    }

    weak var delegate: ExtendedTextFieldDelegate?

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

    private var titleLabel: UILabel!
    private var textField: UITextField!
    private var hintLabel: UILabel!

    init(theme: Theme, type: Type) {
        super.init(frame: CGRectZero)

        createViews(theme: theme, type: type)
        installConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
}

extension ExtendedTextField: UITextFieldDelegate {
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

// Accessibility
extension ExtendedTextField {
    override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set {}
    }

    override var accessibilityLabel: String? {
        get {
            return placeholder ?? title
        }
        set {}
    }

    override var accessibilityHint: String? {
        get {
            var result: String?

            if placeholder != nil {
                // If there is a placeholder also read title as part of the hint.
                result = title
            }

            switch (result, hint) {
                case (.None, _):
                    return hint
                case (.Some, .None):
                    return result
                case (.Some(let r), .Some(let s)):
                    return "\(r), \(s)"
            }
        }
        set {}
    }

    override var accessibilityValue: String? {
        get {
            return text
        }
        set {}
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return textField.accessibilityTraits
        }
        set {}
    }
}

private extension ExtendedTextField {
    func createViews(theme theme: Theme, type: Type) {
        textField = UITextField()
        textField.delegate = self
        textField.borderStyle = .RoundedRect
        textField.autocapitalizationType = .Sentences
        textField.enablesReturnKeyAutomatically = true
        addSubview(textField)

        let textColor: UIColor

        switch type {
            case .Login:
                textColor = theme.colorForType(.NormalText)

                textField.layer.borderColor = theme.colorForType(.LoginButtonBackground).CGColor
                textField.layer.borderWidth = 0.5
                textField.layer.masksToBounds = true
                textField.layer.cornerRadius = 6.0
            case .Normal:
                textColor = theme.colorForType(.NormalText)
        }

        titleLabel = UILabel()
        titleLabel.textColor = textColor
        titleLabel.font = UIFont.systemFontOfSize(18.0)
        titleLabel.backgroundColor = .clearColor()
        addSubview(titleLabel)

        hintLabel = UILabel()
        hintLabel.textColor = textColor
        hintLabel.font = UIFont.antidoteFontWithSize(14.0, weight: .Light)
        hintLabel.numberOfLines = 0
        hintLabel.backgroundColor = .clearColor()
        addSubview(hintLabel)
    }

    func installConstraints() {
        titleLabel.snp_makeConstraints {
            $0.top.leading.trailing.equalTo(self)
        }

        textField.snp_makeConstraints {
            $0.top.equalTo(titleLabel.snp_bottom).offset(Constants.VerticalOffset)
            $0.leading.trailing.equalTo(self)
            $0.height.equalTo(Constants.TextFieldHeight)
        }

        hintLabel.snp_makeConstraints {
            $0.top.equalTo(textField.snp_bottom).offset(Constants.VerticalOffset)
            $0.leading.trailing.equalTo(self)
            $0.bottom.equalTo(self)
        }
    }
}
