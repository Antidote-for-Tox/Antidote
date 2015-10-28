//
//  ErrorHandling.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 26/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

enum ErrorHandlerType {
    case CannotLoadHTML
}

func handleErrorWithType(type: ErrorHandlerType) {
    switch type {
        case .CannotLoadHTML:
            UIAlertView.showErrorWithMessage(String(localized: "error_file_not_found"))
    }
}

extension UIAlertView {
    class func showErrorWithMessage(message: String) {
        showWithTitle(String(localized: "error_title"), message: message)
    }

    class func showWithTitle(title: String, message: String) {
        let alertView = UIAlertView(
                title: title,
                message: message,
                delegate: nil,
                cancelButtonTitle: String(localized: "error_ok_button")).show()
    }
}
