//
//  UIAlertViewExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 28/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

extension UIAlertView {
    class func showErrorWithMessage(message: String) {
        showWithTitle(String(localized: "error_title"), message: message)
    }

    class func showWithTitle(title: String, message: String? = nil) {
        let alertView = UIAlertView(
                title: title,
                message: message,
                delegate: nil,
                cancelButtonTitle: String(localized: "error_ok_button"))

        alertView.show()
    }
}
