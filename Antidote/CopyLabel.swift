// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class CopyLabel: UILabel {
    var copyable = true {
        didSet {
            recognizer.isEnabled = copyable
        }
    }

    fileprivate var recognizer: UITapGestureRecognizer!

    override init(frame: CGRect) {
        super.init(frame: frame)

        isUserInteractionEnabled = true

        recognizer = UITapGestureRecognizer(target: self, action: #selector(CopyLabel.tapGesture))
        addGestureRecognizer(recognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Actions
extension CopyLabel {
    @objc func tapGesture() {
        // This fixes issue with calling UIMenuController after UIActionSheet was presented.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.makeKey()

        becomeFirstResponder()

        let menu = UIMenuController.shared
        menu.setTargetRect(frame, in: superview!)
        menu.setMenuVisible(true, animated: true)
    }
}

// MARK: Copying
extension CopyLabel {
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }

    override var canBecomeFirstResponder : Bool {
        return true
    }
}
