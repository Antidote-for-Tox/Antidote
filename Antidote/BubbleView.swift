// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

private struct Constants {
    static let TextViewMinWidth = 5.0
    static let TextViewMaxWidth = 260.0
    static let TextViewMinHeight = 10.0

    static let TextViewVerticalOffset = 1.0
    static let TextViewHorizontalOffset = 5.0
}

class BubbleView: UIView {
    private var textView: UITextView!

    var text: String? {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
        }
    }

    var textColor: UIColor {
        get {
            return textView.textColor!
        }
        set {
            textView.textColor = newValue
        }
    }

    override var tintColor: UIColor! {
        didSet {
            textView.linkTextAttributes = [
                NSForegroundColorAttributeName: tintColor,
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
            ]
        }
    }

    var selectable: Bool {
        get {
            return textView.selectable
        }
        set {
            textView.selectable = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 12.0
        layer.masksToBounds = true

        textView = UITextView()
        textView.backgroundColor = .clearColor()
        textView.editable = false
        textView.scrollEnabled = false
        textView.dataDetectorTypes = .All
        textView.font = UIFont.systemFontOfSize(16.0)

        addSubview(textView)

        textView.snp_makeConstraints {
            $0.top.equalTo(self).offset(Constants.TextViewVerticalOffset)
            $0.bottom.equalTo(self).offset(-Constants.TextViewVerticalOffset)
            $0.leading.equalTo(self).offset(Constants.TextViewHorizontalOffset)
            $0.trailing.equalTo(self).offset(-Constants.TextViewHorizontalOffset)

            $0.width.greaterThanOrEqualTo(Constants.TextViewMinWidth)
            $0.width.lessThanOrEqualTo(Constants.TextViewMaxWidth)
            $0.height.greaterThanOrEqualTo(Constants.TextViewMinHeight)
        }
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
