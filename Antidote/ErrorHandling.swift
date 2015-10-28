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
            showErrorWithMessage(String(localized: "error_file_not_found"))
    }
}

private func showErrorWithMessage(message: String) {
    UIAlertView(
            title: String(localized: "error_title"),
            message: message,
            delegate: nil,
            cancelButtonTitle: String(localized: "error_ok_button")).show()
}
