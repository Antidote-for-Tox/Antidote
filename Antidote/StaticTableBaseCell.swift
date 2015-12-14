//
//  StaticTableBaseCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 08/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let HorizontalOffset = 20.0
}

class StaticTableBaseCell: BaseCell {
    /**
        View to add all content to.
     */
    var customContentView: UIView!

    private var bottomSeparatorView: UIView!

    func setBottomSeparatorHidden(hidden: Bool) {
        bottomSeparatorView.hidden = hidden
    }

    /**
        Override this method in subclass.
     */
    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        bottomSeparatorView.backgroundColor = theme.colorForType(.TableSeparator)
    }

    /**
        Override this method in subclass.
     */
    override func createViews() {
        super.createViews()

        customContentView = UIView()
        customContentView.backgroundColor = UIColor.clearColor()
        contentView.addSubview(customContentView)

        bottomSeparatorView = UIView()
        contentView.addSubview(bottomSeparatorView)
    }

    /**
        Override this method in subclass.
     */
    override func installConstraints() {
        super.installConstraints()

        customContentView.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(contentView).offset(Constants.HorizontalOffset)
            make.right.equalTo(contentView).offset(-Constants.HorizontalOffset)
            make.top.equalTo(contentView)
        }

        bottomSeparatorView.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(customContentView)
            make.top.equalTo(customContentView.snp_bottom)
            make.right.bottom.equalTo(contentView)
            make.height.equalTo(0.5)
        }
    }
}
