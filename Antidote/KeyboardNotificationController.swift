//
//  KeyboardNotificationController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 25/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class KeyboardNotificationController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)

        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self)
    }

    func keyboardWillShowAnimated(keyboardFrame frame: CGRect) {
        // nop
    }

    func keyboardWillHideAnimated(keyboardFrame frame: CGRect) {
        // nop
    }

    func keyboardWillShowNotification(notification: NSNotification) {
        handleNotification(notification, willShow: true)
    }

    func keyboardWillHideNotification(notification: NSNotification) {
        handleNotification(notification, willShow: false)
    }
}

private extension KeyboardNotificationController {
    func handleNotification(notification: NSNotification, willShow: Bool) {
        let userInfo = notification.userInfo!

        let frame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let curve = UIViewAnimationCurve(rawValue: (userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue)!

        let options: UIViewAnimationOptions

        switch curve {
            case .EaseInOut:
                options = .CurveEaseInOut
            case .EaseIn:
                options = .CurveEaseIn
            case .EaseOut:
                options = .CurveEaseOut
            case .Linear:
                options = .CurveLinear
        }

        UIView.animateWithDuration(duration, delay: 0.0, options: options, animations: { [unowned self] in
            willShow ? self.keyboardWillShowAnimated(keyboardFrame: frame) : self.keyboardWillHideAnimated(keyboardFrame: frame)
        }, completion: nil)
    }
}
