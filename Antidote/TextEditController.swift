//
//  TextEditController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 13/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let Offset = 20.0
    static let FieldHeight = 40.0
}

class TextEditController: UIViewController {
    private let theme: Theme

    private let defaultValue: String?
    private let handler: String -> Void

    private var textField: UITextField!

    /**
        Creates controller for editing single text field.

        - Parameters:
          - theme: Theme controller will use.
          - handler: Handler called when user have finished editing text.
     */
    init(theme: Theme, title: String, defaultValue: String?, handler: String -> Void) {
        self.theme = theme
        self.defaultValue = defaultValue
        self.handler = handler

        super.init(nibName: nil, bundle: nil)

        self.title = title
        edgesForExtendedLayout = .None
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        createTextField()
        installConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        textField.becomeFirstResponder()
    }
}

extension TextEditController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        handler(textField.text ?? "")

        return false
    }
}

private extension TextEditController {
    func createTextField() {
        textField = UITextField()
        textField.text = defaultValue
        textField.delegate = self
        textField.returnKeyType = .Done
        textField.borderStyle = .RoundedRect
        view.addSubview(textField)
    }

    func installConstraints() {
        textField.snp_makeConstraints{ (make) -> Void in
            make.top.equalTo(view).offset(Constants.Offset)
            make.left.equalTo(view).offset(Constants.Offset)
            make.right.equalTo(view).offset(-Constants.Offset)
            make.height.equalTo(Constants.FieldHeight)
        }
    }
}
