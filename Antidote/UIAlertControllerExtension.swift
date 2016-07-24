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

        guard let visible = visibleViewController() else {
            return
        }

        visible.presentViewController(alert, animated: true, completion: nil)
    }

    private class func visibleViewController(rootViewController: UIViewController? = nil) -> UIViewController? {
        var root: UIViewController

        if let rootViewController = rootViewController {
            root = rootViewController
        }
        else {
            let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate

            guard let controller = appDelegate?.window?.rootViewController else {
                return nil
            }

            root = controller
        }

        guard let presented = root.presentedViewController else {
            return root
        }

        if let navigation = presented as? UINavigationController {
            return visibleViewController(navigation.topViewController)
        }
        if let tabBar = presented as? UITabBarController {
            return visibleViewController(tabBar.selectedViewController)
        }

        return presented
    }
}
