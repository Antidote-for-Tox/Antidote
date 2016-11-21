// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

extension UIAlertController {
    class func showErrorWithMessage(_ message: String, retryBlock: ((Void) -> Void)?) {
        showWithTitle(String(localized: "error_title"), message: message, retryBlock: retryBlock)
    }

    class func showWithTitle(_ title: String, message: String? = nil, retryBlock: ((Void) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)


        if let retryBlock = retryBlock {
            alert.addAction(UIAlertAction(title: String(localized: "error_retry_button"), style: .default) { _ in
                retryBlock()
            })

            alert.addAction(UIAlertAction(title: String(localized: "alert_cancel"), style: .cancel, handler: nil))
        }
        else {
            alert.addAction(UIAlertAction(title: String(localized: "error_ok_button"), style: .cancel, handler: nil))
        }

        guard let visible = visibleViewController() else {
            return
        }

        visible.present(alert, animated: true, completion: nil)
    }

    fileprivate class func visibleViewController(_ rootViewController: UIViewController? = nil) -> UIViewController? {
        var root: UIViewController

        if let rootViewController = rootViewController {
            root = rootViewController
        }
        else {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate

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
