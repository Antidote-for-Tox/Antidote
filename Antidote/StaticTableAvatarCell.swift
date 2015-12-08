//
//  StaticTableAvatarCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 03/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let AvatarVerticalOffset = 10.0
}

class StaticTableAvatarCell: StaticTableBaseCell {
    var didTapOnAvatar: (Void -> Void)?

    private var button: UIButton!

    override func setupWithTheme(theme: Theme, model: StaticTableBaseModel) {
        super.setupWithTheme(theme, model: model)

        guard let avatarModel = model as? StaticTableAvatarModel else {
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
        button.layer.cornerRadius = StaticTableAvatarModel.Constants.AvatarImageSize / 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: "buttonPressed", forControlEvents: .TouchUpInside)
        customContentView.addSubview(button)
    }

    override func installConstraints() {
        super.installConstraints()

        button.snp_makeConstraints{ (make) -> Void in
            make.centerX.equalTo(customContentView)
            make.top.equalTo(customContentView).offset(Constants.AvatarVerticalOffset)
            make.bottom.equalTo(customContentView).offset(-Constants.AvatarVerticalOffset)
            make.size.equalTo(StaticTableAvatarModel.Constants.AvatarImageSize)
        }
    }
}

extension StaticTableAvatarCell {
    func buttonPressed() {
        didTapOnAvatar?()
    }
}
