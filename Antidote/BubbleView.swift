//
//  BubbleView.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 16.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let LabelMinWidth = 5.0
    static let LabelMaxWidth = 260.0
    static let LabelMinHeight = 10.0

    static let LabelVerticalOffset = 7.0
    static let LabelHorizontalOffset = 10.0
}

class BubbleView: UIView {
    private var label: UILabel!

    var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
        }
    }

    var textColor: UIColor {
        get {
            return label.textColor
        }
        set {
            label.textColor = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 12.0
        layer.masksToBounds = true

        label = UILabel()
        label.font = UIFont.systemFontOfSize(16.0)
        label.numberOfLines = 0
        addSubview(label)

        label.snp_makeConstraints {
            $0.top.equalTo(self).offset(Constants.LabelVerticalOffset)
            $0.bottom.equalTo(self).offset(-Constants.LabelVerticalOffset)
            $0.left.equalTo(self).offset(Constants.LabelHorizontalOffset)
            $0.right.equalTo(self).offset(-Constants.LabelHorizontalOffset)

            $0.width.greaterThanOrEqualTo(Constants.LabelMinWidth)
            $0.width.lessThanOrEqualTo(Constants.LabelMaxWidth)
            $0.height.greaterThanOrEqualTo(Constants.LabelMinHeight)
        }
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
