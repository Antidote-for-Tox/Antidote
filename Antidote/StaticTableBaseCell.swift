//
//  StaticTableBaseCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 08/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

class StaticTableBaseCell: UITableViewCell {
    private var bottomSeparatorView: UIView!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        createSeparatorView()
        installConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
        Override this method in subclass
     */
    func setupWithTheme(theme: Theme, model: StaticTableBaseModel) {
        bottomSeparatorView.backgroundColor = theme.colorForType(.TableSeparator)
    }

    func setBottomSeparatorHidden(hidden: Bool) {
        bottomSeparatorView.hidden = hidden
    }
}

private extension StaticTableBaseCell {
    func createSeparatorView() {
        bottomSeparatorView = UIView()
        contentView.addSubview(bottomSeparatorView)
    }

    func installConstraints() {
        bottomSeparatorView.snp_makeConstraints{ (make) -> Void in
            make.left.right.bottom.equalTo(contentView)
            make.height.equalTo(0.5)
        }
    }
}
