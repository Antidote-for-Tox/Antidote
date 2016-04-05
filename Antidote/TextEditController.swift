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
    private let changeTextHandler: String -> Void
    private let userFinishedEditing: Void -> Void

    private var textField: UITextField!

    /**
        Creates controller for editing single text field.

        - Parameters:
          - theme: Theme controller will use.
          - changeTextHandler: Handler called when user have changed the text.
          - userFinishedEditing: Handler called when user have finished editing.
     */
    init(theme: Theme, title: String, defaultValue: String?, changeTextHandler: String -> Void, userFinishedEditing: Void -> Void) {
        self.theme = theme
        self.defaultValue = defaultValue
        self.changeTextHandler = changeTextHandler
        self.userFinishedEditing = userFinishedEditing

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

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        changeTextHandler(textField.text ?? "")
    }
}

extension TextEditController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        changeTextHandler(textField.text ?? "")
        userFinishedEditing()

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
        textField.snp_makeConstraints {
            $0.top.equalTo(view).offset(Constants.Offset)
            $0.leading.equalTo(view).offset(Constants.Offset)
            $0.trailing.equalTo(view).offset(-Constants.Offset)
            $0.height.equalTo(Constants.FieldHeight)
        }
    }
}
