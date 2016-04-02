//
//  CopyLabel.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 14.02.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit

class CopyLabel: UILabel {
    var copyable = true {
        didSet {
            recognizer.enabled = copyable
        }
    }

    private var recognizer: UITapGestureRecognizer!

    override init(frame: CGRect) {
        super.init(frame: frame)

        userInteractionEnabled = true

        recognizer = UITapGestureRecognizer(target: self, action: #selector(CopyLabel.tapGesture))
        addGestureRecognizer(recognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Actions
extension CopyLabel {
    func tapGesture() {
        // This fixes issue with calling UIMenuController after UIActionSheet was presented.
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.makeKeyWindow()

        becomeFirstResponder()

        let menu = UIMenuController.sharedMenuController()
        menu.setTargetRect(frame, inView: superview!)
        menu.setMenuVisible(true, animated: true)
    }
}

// MARK: Copying
extension CopyLabel {
    override func copy(sender: AnyObject?) {
        UIPasteboard.generalPasteboard().string = text
    }

    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return action == #selector(NSObject.copy(_:))
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }
}
