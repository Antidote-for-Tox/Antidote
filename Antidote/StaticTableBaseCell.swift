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
    static let LeftOffset = 20.0
}

class StaticTableBaseCell: UITableViewCell {
    /**
        View to add all content to.
     */
    var customContentView: UIView!

    private var bottomSeparatorView: UIView!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        createViews()
        installConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setBottomSeparatorHidden(hidden: Bool) {
        bottomSeparatorView.hidden = hidden
    }

    /**
        Override this method in subclass.
     */
    func setupWithTheme(theme: Theme, model: StaticTableBaseModel) {
        bottomSeparatorView.backgroundColor = theme.colorForType(.TableSeparator)
    }

    /**
        Override this method in subclass.
     */
    func createViews() {
        customContentView = UIView()
        customContentView.backgroundColor = UIColor.clearColor()
        contentView.addSubview(customContentView)

        bottomSeparatorView = UIView()
        customContentView.addSubview(bottomSeparatorView)
    }

    /**
        Override this method in subclass.
     */
    func installConstraints() {
        customContentView.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(contentView).offset(Constants.LeftOffset)
            make.top.bottom.right.equalTo(contentView)
        }

        bottomSeparatorView.snp_makeConstraints{ (make) -> Void in
            make.left.right.bottom.equalTo(customContentView)
            make.height.equalTo(0.5)
        }
    }
}
