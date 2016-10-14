// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

private struct Constants {
    static let AvatarVerticalOffset = 10.0
}

class StaticTableAvatarCell: StaticTableBaseCell {
    private var didTapOnAvatar: (StaticTableAvatarCell -> Void)?

    private var button: UIButton!

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let avatarModel = model as? StaticTableAvatarCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        selectionStyle = .None

        button.userInteractionEnabled = avatarModel.userInteractionEnabled
        button.setImage(avatarModel.avatar, forState: .Normal)
        didTapOnAvatar = avatarModel.didTapOnAvatar
    }

    override func createViews() {
        super.createViews()

        button = UIButton()
        button.layer.cornerRadius = StaticTableAvatarCellModel.Constants.AvatarImageSize / 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(StaticTableAvatarCell.buttonPressed), forControlEvents: .TouchUpInside)
        customContentView.addSubview(button)
    }

    override func installConstraints() {
        super.installConstraints()

        button.snp_makeConstraints {
            $0.centerX.equalTo(customContentView)
            $0.top.equalTo(customContentView).offset(Constants.AvatarVerticalOffset)
            $0.bottom.equalTo(customContentView).offset(-Constants.AvatarVerticalOffset)
            $0.size.equalTo(StaticTableAvatarCellModel.Constants.AvatarImageSize)
        }
    }
}

extension StaticTableAvatarCell {
    func buttonPressed() {
        didTapOnAvatar?(self)
    }
}
