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
            showErrorWithMessage(String(localized: "File not found"))
    }
}

private func showErrorWithMessage(message: String) {
    UIAlertView(
            title: String(localized: "Error"),
            message: message,
            delegate: nil,
            cancelButtonTitle: String(localized: "OK")).show()
}
