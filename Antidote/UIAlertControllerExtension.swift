//
//  UIAlertControllerExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 11.04.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit

extension UIAlertController {
    class func showErrorWithMessage(message: String, retryBlock: (Void -> Void)?) {
        showWithTitle(String(localized: "error_title"), message: message, retryBlock: retryBlock)
    }

    class func showWithTitle(title: String, message: String? = nil, retryBlock: (Void -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)


        if let retryBlock = retryBlock {
            alert.addAction(UIAlertAction(title: String(localized: "error_retry_button"), style: .Default) { _ in
                retryBlock()
            })

            alert.addAction(UIAlertAction(title: String(localized: "alert_cancel"), style: .Cancel, handler: nil))
        }
        else {
            alert.addAction(UIAlertAction(title: String(localized: "error_ok_button"), style: .Cancel, handler: nil))
        }

        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        guard let root = appDelegate?.window?.rootViewController else {
            return
        }

        root.presentViewController(alert, animated: true, completion: nil)
    }
}
