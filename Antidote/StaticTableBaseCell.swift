// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

private struct Constants {
    static let HorizontalOffset = 20.0
    static let MinHeight = 50.0
}

class StaticTableBaseCell: BaseCell {
    /**
        View to add all content to.
     */
    var customContentView: UIView!

    fileprivate var bottomSeparatorView: UIView!

    func setBottomSeparatorHidden(_ hidden: Bool) {
        bottomSeparatorView.isHidden = hidden
    }

    /**
        Override this method in subclass.
     */
    override func setupWithTheme(_ theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        bottomSeparatorView.backgroundColor = theme.colorForType(.SeparatorsAndBorders)
    }

    /**
        Override this method in subclass.
     */
    override func createViews() {
        super.createViews()

        customContentView = UIView()
        customContentView.backgroundColor = UIColor.clear
        contentView.addSubview(customContentView)

        bottomSeparatorView = UIView()
        contentView.addSubview(bottomSeparatorView)
    }

    /**
        Override this method in subclass.
     */
    override func installConstraints() {
        super.installConstraints()

        customContentView.snp.makeConstraints {
            $0.leading.equalTo(contentView).offset(Constants.HorizontalOffset)
            $0.trailing.equalTo(contentView).offset(-Constants.HorizontalOffset)
            $0.top.equalTo(contentView)
            $0.height.greaterThanOrEqualTo(Constants.MinHeight)
        }

        bottomSeparatorView.snp.makeConstraints {
            $0.leading.equalTo(customContentView)
            $0.top.equalTo(customContentView.snp.bottom)
            $0.trailing.bottom.equalTo(contentView)
            $0.height.equalTo(0.5)
        }
    }
}
